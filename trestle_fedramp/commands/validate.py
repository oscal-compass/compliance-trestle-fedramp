# -*- mode:python; coding:utf-8 -*-

# Copyright (c) 2021 IBM Corp. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Trestle FedRAMP Validate Command."""

import argparse
import json
import logging
import pathlib

import trestle.common.log as log
from trestle.core.commands.common import return_codes
from trestle.core import parser
from trestle.core.commands.command_docs import CommandBase
from trestle.common.file_utils import load_file

from trestle_fedramp.core.fedramp import FedrampValidator

logger = logging.getLogger(__name__)


class ValidateCmd(CommandBase):
    """Validate contents of an OSCAL model based on FedRAMP specifications."""

    name = 'fedramp-validate'

    def _init_arguments(self) -> None:
        logger.debug('Init arguments')
        self.add_argument('-f', '--file', help='OSCAL file to validate.', type=str, required=True)

        self.add_argument(
            '-o', '--output-dir', help='Output directory for validation results.', type=str, required=True
        )

    def _run(self, args: argparse.Namespace) -> int:
        logger.debug('Entering trestle fedramp-validate.')

        log.set_log_level_from_args(args)

        model_file = pathlib.Path(args.file).resolve()
        if not model_file.exists():
            logger.warning(f'Input file {args.file} does not exist.')
            return return_codes.CmdReturnCodes.COMMAND_ERROR.value

        output_dir = pathlib.Path(args.output_dir).resolve()
        if not output_dir.exists():
            logger.warning(f'Output dir {args.output_dir} does not exist.')
            return return_codes.CmdReturnCodes.COMMAND_ERROR.value

        try:
            data = load_file(model_file)
            model = parser.root_key(data)
            if model != 'system-security-plan':
                logger.warning(f'Validation for {model} is not supported.')
                return return_codes.CmdReturnCodes.COMMAND_ERROR.value
            data_str = json.dumps(data)
            validator = FedrampValidator()
            valid = validator.validate_ssp(data_str, str(model_file).split('.')[-1], output_dir)
        except Exception as error:
            logger.error(f'Unexpected error: {error}')
            return return_codes.CmdReturnCodes.COMMAND_ERROR.value

        return return_codes.CmdReturnCodes.SUCCESS.value if valid else return_codes.CmdReturnCodes.COMMAND_ERROR.value
