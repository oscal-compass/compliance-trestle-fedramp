# Copyright (c) 2021 IBM Corp. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""FedRAMP Validation API."""

import logging
import pathlib
import sys
import tempfile
from importlib.resources import files

from saxonche import (PySaxonApiError, PySaxonProcessor, PyXslt30Processor)

from trestle.common.err import TrestleError

import trestle_fedramp.const as const
from trestle_fedramp.core.format_convert import JsonXmlConverter

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(sys.stdout))


class FedrampValidator:
    """Validator for FedRAMP compliant OSCAL documents."""

    def __init__(self):
        """Intialize FedRAMP validator."""
        self.baselines_path = files('trestle_fedramp.resources').joinpath(const.FEDRAM_BASELINE)

        if not self.baselines_path.exists():
            raise TrestleError(f'Fedramp baseline directory {self.baselines_path} does not exist')

        self.registry_path = files('trestle_fedramp.resources').joinpath(const.FEDRAMP_REGISTRY)
        if not self.registry_path.exists():
            raise TrestleError(f'Fedramp registry directory {self.registry_path} does not exist')

        self.ssp_xsl_path = files('trestle_fedramp.resources').joinpath(const.FEDRAMP_SSP_XSL)

        self.svrl_xsl_path = files('trestle_fedramp.resources').joinpath(const.FEDRAM__SVRL_XSL)

        logger.debug(f'Baselines dir: {self.baselines_path}')
        logger.debug(f'Registry dir: {self.registry_path}')
        logger.debug(f'SSP XSL file: {self.ssp_xsl_path}')
        logger.debug(f'SVRL XSL file: {self.svrl_xsl_path}')

    def validate_ssp(self, ssp_content: str, data_format: str, output_dir: pathlib.Path = None) -> bool:
        """Validate the given SSP content as per FedRAMP validation rules."""
        if output_dir is None:
            output_dir = pathlib.Path.cwd()

        if not self.ssp_xsl_path.exists():
            raise TrestleError(f'SSP validation (xsl file) {self.ssp_xsl_path} does not exist')

        if data_format.upper() == 'JSON':
            converter = JsonXmlConverter()
            xml_content = converter.json2xml('ssp', ssp_content)
            if xml_content is None:
                raise TrestleError('Error converting JSON to XML')
        elif data_format.upper() == 'XML':
            xml_content = ssp_content
        else:
            raise TrestleError(f'Unknown SSP format {data_format}')

        # Create a temporary directory for short-lived files
        with tempfile.TemporaryDirectory(dir=output_dir) as temp_dir:
            working_dir = pathlib.Path(temp_dir)
            return self._validate_xml_content(xml_content, working_dir, output_dir)

    def _validate_xml_content(self, xml_content: str, working_dir: pathlib.Path, output_dir: pathlib.Path) -> bool:
        """Validate the given xml content as per FedRAMP validation rules."""
        logger.info('Validating SSP')
        try:
            saxon_proc = PySaxonProcessor(license=False)
            xslt_proc = self._get_xslt_processor(saxon_proc)

            # write the xml content to a file in the working dir
            # this is needed because the xslt processor requires a file path
            source_file = working_dir / 'ssp.xml'
            with open(str(source_file), 'w') as f:
                f.write(xml_content)
                logger.debug(f'SSP written to file: {source_file}')

            # Validate the SSP, returning an SVRL document as a string
            svrl_str = xslt_proc.transform_to_string(
                source_file=str(source_file),
                stylesheet_file=str(self.ssp_xsl_path),
            )

            svrl_node = saxon_proc.parse_xml(xml_text=svrl_str)
            xpath_proc = saxon_proc.new_xpath_processor()
            xpath_proc.set_context(xdm_item=svrl_node)

            value = xpath_proc.evaluate('//*:failed-assert')
            if value is not None:
                output = output_dir / 'fedramp-validation-report.xml'
                with open(str(output), 'w') as f:
                    f.write(str(value))
                    logger.info(f'Failed assertion written to file: {output}')

                # transform svrl output to html
                if self.svrl_xsl_path is not None:

                    # Write svrl output to file
                    svrl_output = working_dir / 'svrl.xml'
                    with open(str(svrl_output), 'w') as f:
                        f.write(svrl_str)
                        logger.debug(f'SVRL written to file: {svrl_output}')

                    html = xslt_proc.transform_to_string(
                        source_file=str(svrl_output), stylesheet_file=str(self.svrl_xsl_path)
                    )
                    output = output_dir / 'fedramp-validation-report.html'
                    with open(str(output), 'w') as f:
                        f.write(html)
                        logger.info(f'HTML output of Failed assertion written to file: {output}')
                # there are failures; validation failed
                return False

            return True
        except PySaxonApiError as e:
            raise TrestleError(f'Error during SSP validation: {e}')

    def _get_xslt_processor(self, saxon_processor: PySaxonProcessor) -> PyXslt30Processor:
        """Create a new XSLT processor and set parameters."""
        xslt_processor = saxon_processor.new_xslt30_processor()
        # Set parameters for FedRAMP baselines and fedramp-values files
        xslt_processor.set_parameter('baselines-base-path', saxon_processor.make_string_value(str(self.baselines_path)))
        xslt_processor.set_parameter('registry-base-path', saxon_processor.make_string_value(str(self.registry_path)))
        # Set to True to validate external resource references
        xslt_processor.set_parameter('param-use-remote-resources', saxon_processor.make_boolean_value(False))
        return xslt_processor
