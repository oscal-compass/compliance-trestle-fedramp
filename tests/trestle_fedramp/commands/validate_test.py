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
"""Testing fedramp validation command functionality."""

import argparse
import logging
import pathlib
from typing import Any

from tests import test_utils

from trestle_fedramp.commands.validate import ValidateCmd

xml_report = 'fedramp-validation-report.xml'
html_report = 'fedramp-validation-report.html'


def test_validate_ssp(tmp_path: pathlib.Path, tmp_trestle_dir: pathlib.Path) -> None:
    """Test Fedramp SSP validation command."""
    file_path = pathlib.Path(test_utils.JSON_FEDRAMP_SSP_PATH) / test_utils.JSON_FEDRAMP_SSP_NAME
    args = argparse.Namespace(file=str(file_path), output_dir=str(tmp_path), trestle_root=tmp_trestle_dir, verbose=1)
    rc = ValidateCmd()._run(args)
    assert rc != 0

    assert (tmp_path / xml_report).exists()
    assert (tmp_path / html_report).exists()


def test_validate_ssp_unsupported_format(tmp_path: pathlib.Path, tmp_trestle_dir: pathlib.Path, caplog: Any) -> None:
    """Test Fedramp SSP validation command with unsupported format."""
    file_path = pathlib.Path(test_utils.XML_FEDRAMP_SSP_PATH) / test_utils.XML_FEDRAMP_SSP_NAME
    args = argparse.Namespace(file=str(file_path), output_dir=str(tmp_path), trestle_root=tmp_trestle_dir, verbose=1)
    rc = ValidateCmd()._run(args)
    assert rc != 0

    expected_message = 'Unsupported file extension .xml'
    assert any(record.levelno == logging.ERROR and expected_message in record.message for record in caplog.records)


def test_validate_wrong_model(tmp_path: pathlib.Path, tmp_trestle_dir: pathlib.Path, caplog: Any) -> None:
    """Test fails with wrong model file."""
    file_path = pathlib.Path(test_utils.JSON_FEDRAMP_SAR_PATH) / test_utils.JSON_FEDRAMP_SAR_NAME
    args = argparse.Namespace(file=str(file_path), output_dir=str(tmp_path), trestle_root=tmp_trestle_dir, verbose=1)
    rc = ValidateCmd()._run(args)
    assert rc != 0

    expected_message = 'Validation for assessment-results is not supported'
    assert any(record.levelno == logging.WARNING and expected_message in record.message for record in caplog.records)


def test_validate_invalid_trestle_root(tmp_path: pathlib.Path, tmp_trestle_dir: pathlib.Path, caplog: Any) -> None:
    """Test fails with an invalid trestle root."""
    file_path = pathlib.Path(test_utils.JSON_FEDRAMP_SSP_PATH) / test_utils.JSON_FEDRAMP_SSP_NAME
    args = argparse.Namespace(file=str(file_path), output_dir=str(tmp_path), trestle_root=tmp_path, verbose=1)
    rc = ValidateCmd()._run(args)
    assert rc != 0
