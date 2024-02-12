# -*- mode:python; coding:utf-8 -*-

# Copyright (c) 2024 IBM Corp. All rights reserved.
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
"""Testing reading OSCAL SSP data for FedRAMP transformation."""

import pathlib
from typing import Tuple

import pytest

from trestle.common.const import NAMESPACE_FEDRAMP
from trestle.common.model_utils import ModelUtils
from trestle.core.generators import generate_sample_model
from trestle.oscal import ssp
from trestle.oscal.common import Property

from trestle_fedramp.core.ssp_reader import (ControlOrigination, FedrampControlDict, FedrampSSPReader)


def test_control_origination() -> None:
    """Test valid and invalid control origination values."""
    assert ControlOrigination.get_long_name(['sp-corporate']) == 'Service Provider Corporate'
    assert ControlOrigination.get_long_name(['sp-system']) == 'Service Provider System Specific'
    assert (
        ControlOrigination.get_long_name(['customer-configured']) == 'Configured by Customer (Customer System Specific)'
    )
    assert ControlOrigination.get_long_name(['customer-provided']) == 'Provided by Customer (Customer System Specific)'
    assert ControlOrigination.get_long_name(['inherited']) == 'Inherited'
    assert (
        ControlOrigination.get_long_name(['sp-corporate',
                                          'sp-system']) == 'Service Provider Hybrid (Corporate and System Specific)'
    )
    assert (
        ControlOrigination.get_long_name(['sp-corporate', 'customer-configured']
                                         ) == 'Shared (Service Provider and Customer Responsibility)'
    )

    # Assert that if the input is not a valid control origination value, it raises a ValueError.
    with pytest.raises(ValueError, match='Invalid control origination value: invalid. Use one of .*'):
        ControlOrigination.get_long_name(['invalid'])

    # Validate error for an invalid combination of control origination values.
    with pytest.raises(ValueError, match='Invalid control origination values: .*'):
        ControlOrigination.get_long_name(['inherited', 'customer-configured'])


def test_reader_control_origination(tmp_trestle_dir_with_ssp: Tuple[pathlib.Path, str]) -> None:
    """Test retrieving control origination values from the SSP."""
    tmp_trestle_dir, ssp_name = tmp_trestle_dir_with_ssp

    ssp_reader: FedrampSSPReader = FedrampSSPReader(tmp_trestle_dir)

    ssp_file_path = ModelUtils.get_model_path_for_name_and_class(tmp_trestle_dir, ssp_name, ssp.SystemSecurityPlan)
    assert ssp_file_path is not None
    ssp_control_dict: FedrampControlDict = ssp_reader.read_ssp_data(ssp_file_path)
    assert len(ssp_control_dict) > 0

    # Verify the control origination values for the implemented requirements.
    assert ssp_control_dict['AC-1'].control_origination == 'Service Provider System Specific'
    assert ssp_control_dict['AC-2'].control_origination == 'Shared (Service Provider and Customer Responsibility)'
    assert ssp_control_dict['AU-1'].control_origination == 'Service Provider Corporate'


def test_get_control_origination() -> None:
    """Test getting control origination from the implemented requirement."""
    ssp_reader: FedrampSSPReader = FedrampSSPReader(pathlib.Path.cwd())
    impl_req = generate_sample_model(ssp.ImplementedRequirement)
    impl_req.props = []
    impl_req.props.append(
        Property(name='control-origination', value='sp-corporate', ns='https://example.com')  # type: ignore
    )

    # This should be none because the namespace is not the FedRAMP namespace.
    assert ssp_reader._get_control_origination_values(impl_req) is None

    impl_req.props = []
    impl_req.props.append(
        Property(name='control-origination', value='sp-corporate', ns=NAMESPACE_FEDRAMP)  # type: ignore
    )

    # This should return the long name of the control origination value.
    assert ssp_reader._get_control_origination_values(impl_req) == 'Service Provider Corporate'
