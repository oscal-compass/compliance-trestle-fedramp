# -*- mode:python; coding:utf-8 -*-

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
"""Testing docx utility classes."""

from docx.document import Document as DocxDocument  # type: ignore

import pytest

from tests.test_utils import (
    verify_control_origination_checkboxes,
    verify_implementation_status_checkboxes,
    verify_parameters,
    verify_responses,
    verify_responsible_roles
)

from trestle.common.err import TrestleError

from trestle_fedramp import const
from trestle_fedramp.core.docx_helper import ControlImplementationDescriptions, ControlSummaries, FedrampDocx
from trestle_fedramp.core.ssp_reader import FedrampControlDict, FedrampSSPData


def test_fedramp_docx_populate(docx_document: DocxDocument, test_ssp_control_dict: FedrampControlDict) -> None:
    """Test FedRAMP docx populate and verify the correct controls are populated."""
    fedramp_docx = FedrampDocx(docx_document, test_ssp_control_dict)
    fedramp_docx.populate()

    # Read the table information validate the proper check boxes are populated
    control_summaries = ControlSummaries()
    control_implementation_description = ControlImplementationDescriptions()
    for table in docx_document.tables:
        row_header = table.rows[0].cells[0].text
        if control_summaries.is_control_summary_table(row_header):
            control_id = fedramp_docx.get_control_id(row_header)
            data: FedrampSSPData = test_ssp_control_dict.get(control_id, FedrampSSPData({}, {}, None, None, None))
            verify_control_origination_checkboxes(table.cell(*control_summaries._control_origination_cell), data)
            verify_implementation_status_checkboxes(table.cell(*control_summaries._implementation_status_cell), data)
            # Check that the parameters are in the cell text (partial match)
            verify_parameters(table, data.parameters, partial_match=True)
            verify_responsible_roles(table.cell(*control_summaries._responsible_role_cell), data)
        if control_implementation_description.is_control_implementation_table(row_header):
            control_id = fedramp_docx.get_control_id(row_header)
            data = test_ssp_control_dict.get(control_id, FedrampSSPData({}, {}, None, None, None))
            # Check that the responses are in the cell text (partial match)
            verify_responses(table, data.control_implementation_description, partial_match=True)


def test_fedramp_docx_with_invalid_input(docx_document: DocxDocument) -> None:
    """Trigger and error with invalid input."""
    # AC-1 does not have an control origination inherited value
    invalid_control_dict: FedrampControlDict = {
        'AC-1': FedrampSSPData(
            control_implementation_description={},
            parameters={},
            control_origination=[const.FEDRAMP_INHERITED],
            implementation_status=None,
            responsible_roles=None
        )
    }
    fedramp_docx = FedrampDocx(docx_document, invalid_control_dict)

    with pytest.raises(TrestleError, match='.*Invalid control origination: Inherited'):
        fedramp_docx.populate()


def test_fedramp_docx_with_non_existent_values(docx_document: DocxDocument) -> None:
    """Trigger and error with a non-existent control origination and implementation status."""
    # AC-1 does not have an control origination inherited value
    invalid_control_dict: FedrampControlDict = {
        'AC-1': FedrampSSPData(
            control_implementation_description={},
            parameters={},
            control_origination=['invalid'],
            implementation_status=None,
            responsible_roles=None
        )
    }
    fedramp_docx = FedrampDocx(docx_document, invalid_control_dict)

    with pytest.raises(TrestleError, match='.*Invalid FedRAMP control origination value: invalid'):
        fedramp_docx.populate()

    invalid_control_dict['AC-1'].control_origination = [const.FEDRAMP_SP_CORPORATE]  # Reset the control origination
    invalid_control_dict['AC-1'].implementation_status = 'invalid'

    with pytest.raises(TrestleError, match='.*Invalid FedRAMP implementation status value: invalid'):
        fedramp_docx.populate()


def test_get_control_id() -> None:
    """Test FedRAMP docx get control id."""
    test_row_header = 'AC-2 Control Summary Information'
    control_label = FedrampDocx.get_control_id(test_row_header)
    assert control_label == 'AC-2'
