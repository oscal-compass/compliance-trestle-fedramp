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
"""Core constants module containing all constants."""

# FedRAMP related files and directories
FEDRAM_BASELINE = 'fedramp-source/content/baselines/rev4/xml'
FEDRAMP_REGISTRY = 'fedramp-source/content/resources/xml'
FEDRAM__SVRL_XSL = 'fedramp-source/vendor/svrl2html.xsl'
FEDRAMP_SSP_XSL = 'fedramp-source/ssp.xsl'

# NIST related files for format conversion
NIST_SSP_JSON_XML_XSL = 'nist-source/xml/convert/oscal_ssp_json-to-xml-converter-new.xsl'
NIST_INITIAL_TEMPLATE = 'from-json'
NIST_FILE_PARAM_NAME = 'file'
