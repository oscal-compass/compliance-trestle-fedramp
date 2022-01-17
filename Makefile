# -*- mode:makefile; coding:utf-8 -*-

# Copyright (c) 2020 IBM Corp. All rights reserved.
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


develop:
	python -m pip install -e .[dev] --upgrade --upgrade-strategy eager --

pre-commit: 
	pre-commit install

pre-commit-update:
	pre-commit autoupdate

install:
	python -m pip install  --upgrade pip setuptools
	python -m pip install . --upgrade -vvv --upgrade-strategy eager

code-format: pre-commit-update
	pre-commit run yapf --all-files

code-lint: pre-commit-update
	pre-commit run flake8 --all-files

code-typing:
	mypy --pretty trestle

test::
	python -m pytest -vvvv --exitfirst -n auto

test-cov::
	python -m pytest -vvvv --cov=trestle_fedramp -n auto  --cov-report=xml --cov-fail-under=0

test-all-random::
	python -m pytest --cov=trestle_fedramp --cov-report=xml --random-order

test-verbose:
	python -m pytest  -vv -n auto

test-speed-measure:
	python -m pytest -n auto --durations=30 


test-bdist:: clean
	. tests/manual_tests/test_binary.sh


release::
	git config --global user.name "semantic-release (via Github actions)"
	git config --global user.email "semantic-release@github-actions"
	semantic-release publish


mdformat: pre-commit-update
	pre-commit run mdformat --all-files


fedramp-copy:
	mkdir -p trestle_fedramp/resources/fedramp-source/content/baselines/rev4
	cp -R fedramp-source/dist/content/baselines/rev4/xml trestle_fedramp/resources/fedramp-source/content/baselines/rev4/
	mkdir -p trestle_fedramp/resources/fedramp-source/content/resources
	cp -R fedramp-source/dist/content/resources/xml trestle_fedramp/resources/fedramp-source/content/resources/
	mkdir -p trestle_fedramp/resources/fedramp-source/vendor
	cp ssp.xsl trestle_fedramp/resources/fedramp-source/
	cp fedramp-source/vendor/svrl2html.xsl trestle_fedramp/resources/fedramp-source/vendor/
	mkdir -p trestle_fedramp/resources/nist-source/xml
	cp -R nist-source/xml/convert trestle_fedramp/resources/nist-source/xml/
	cp oscal_ssp_json-to-xml-converter-new.xsl trestle_fedramp/resources/nist-source/xml/convert/


# POSIX ONLY
clean::
	rm -rf build
	rm -rf dist
	rm -rf .pytest_cache
	rm -rf tmp_bin_test
	rm -rf cov_html
	rm -rf coverage.xml
	rm -rf .coverage*
	rm -rf .mypy_cache
	find . | grep -E "__pycache__|\.pyc|\.pyo" | xargs rm -rf

pylint:
	pylint trestle_fedramp

pylint-test:
	pylint tests --rcfile=.pylintrc_tests



