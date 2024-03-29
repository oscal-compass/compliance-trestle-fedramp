## Contributing In General

Our project welcomes external contributions. If you have an itch, please feel
free to scratch it.

To contribute code or documentation, please submit a [pull request](https://github.com/oscal-compass/compliance-trestle-fedramp/pulls).

A good way to familiarize yourself with the codebase and contribution process is
to look for and tackle low-hanging fruit in the [issue tracker](https://github.com/oscal-compass/compliance-trestle-fedramp/issues).
Before embarking on a more ambitious contribution, please quickly [get in touch](https://oscal-compass.github.io/compliance-trestle-fedramp/maintainers/) with us.

**Note: We appreciate your effort, and want to avoid a situation where a contribution
requires extensive rework (by you or by us), sits in backlog for a long time, or
cannot be accepted at all!**

We have also adopted [Contributor Covenant Code of Conduct](https://oscal-compass.github.io/compliance-trestle/mkdocs_code_of_conduct/).

### Proposing new features

If you would like to implement a new feature, please [raise an issue](https://github.com/oscal-compass/compliance-trestle-fedramp/issues)
labelled `enhancement` before sending a pull request so the feature can be discussed. This is to avoid
you wasting your valuable time working on a feature that the project developers
are not interested in accepting into the code base.

### Fixing bugs

If you would like to fix a bug, please [raise an issue](https://github.com/oscal-compass/compliance-trestle-fedramp/issues) labelled `bug` before sending a
pull request so it can be tracked.

### Merge approval

The project maintainers use LGTM (Looks Good To Me) in comments on the code
review to indicate acceptance. A change requires LGTMs from one of the maintainers.

For a list of the maintainers, see the [maintainers](https://github.com/oscal-compass/compliance-trestle-fedramp/blob/develop/MAINTAINERS.md) page.

### Merging and release workflow

The `compliance-trestle-fedramp` follows the same release and merging workflow `trestle` follows. Please refer to the [trestle release and merging workflow](https://github.com/oscal-compass/compliance-trestle/blob/develop/CONTRIBUTING.md#trestle-merging-and-release-workflow).

## Typing, docstrings and documentation

The `compliance-trestle-fedramp` project uses type hints and docstrings to improve code readability and maintainability. Please refer to the [trestle typing, docstrings and documentation](https://github.com/oscal-compass/compliance-trestle/blob/develop/CONTRIBUTING.md#typing-docstrings-and-documentation) for more details.

## Legal

By contributing to this project, you agree to license your contribution under the \[Apache 2.0 License\]. For more detailed requirements, please refer to the `trestle`  Legal section in the [CONTRIBUTING.md](https://github.com/oscal-compass/compliance-trestle/blob/develop/CONTRIBUTING.md#legal).

## Setup - Developing `trestle`

### Does `compliance-trestle-fedramp` run correctly on my platform

- (Optional) setup a venv for python
- Run `make develop`
  - This will install all python dependencies
  - It will also checkout the submodules required for testing.
- Run `make test`
  - This *should* run on all platforms, except Windows (currently).

### Setting up `vscode` for python.

- Use the following commands to setup python:

```bash
python3 -m venv venv
. ./venv/bin/activate
# for zsh put .[dev] in quotes as below
pip install -q -e ".[dev]" --upgrade --upgrade-strategy eager
```

- Install vscode plugin `Python extension for Visual Studio Code`

- Enable `yapf` for code formatting

- Enable `flake8` for code linting

### Testing python in `vscode`

Tests should be in the test subdirectory. Each file should be named test\_\*.py and each test function should be named \*\_test().

Note that with Python3 there should be no need for __init__.py in directories.

Test discovery should be automatic when you select a .py file for editing. After tests are discovered a flask icon will appear on the left and you can select it to see a panel listing of your tests.  In addition your test functions will be annotated with Run/Debug so they can be launched directly from the editor.  When everything is set up properly you should be able to step through your test code - which is important.

Sometimes the discovery fails - and you may need to resort to uninstalling the python extension and reinstalling it - perhaps also shutting down code and restarting.  This is a lightweight operation and seems to be safe and usually fixes any problems.

Test discovery will fail or stop if any of the tests have errors in them - so be sure to monitor the Problems panel at the bottom for problems in the code.

Note that there are many panels available in Output - so be sure to check `Python Test Log` for errors and output from the tests.

pytest fixtures are available to allow provision of common functionality.  See conftest.py and tmp_dir for an example.

#### FedRAMP sources for development and testing

The `trestle` FedRAMP plugin relies on reference data from the FedRAMP automation repository testing and development. The FedRAMP automation repository is a submodule in the trestle project. The FedRAMP automation repository is located at: https://github.com/GSA/fedramp-automation

In order to develop/test, the submodule must be checked out with `git submodule update --init` or `make submodules`.

To copy required files from the submodule to the trestle-fedramp plugin, run `make fedramp-copy`.

#### NIST OSCAL sources for development and testing

To perform conversions from JSON to XML and vice versa, the `trestle` FedRAMP plugin relies on the NIST OSCAL schema and examples. There are available as release artifacts in the NIST OSCAL repository. The NIST OSCAL repository is located at: https://github.com/usnistgov/OSCAL

To retrieve these artifacts, run `make download-release-artifacts`.

### Code style and formatting

The `trestle` FedRAMP plugin uses [yapf](https://github.com/google/yapf) for code formatting and [flake8](https://flake8.pycqa.org/en/latest/) for code styling.  It also uses [pre-commit](https://pre-commit.com/) hooks that are integrated into the development process and the CI. When you run `make develop` you are ensuring that the pre-commit hooks are installed and updated to their latest versions for this repository. This ensures that all delivered code has been properly formatted
and passes the linter rules.  See the [pre-commit configuration file](https://github.com/oscal-compass/compliance-trestle-fedramp/blob/develop/.pre-commit-config.yaml) for details on
`yapf` and `flake8` configurations.

Since `yapf` and `flake8` are installed as part of the `pre-commit` hooks, running `yapf` and `flake8`
manually must be done through `pre-commit`.  See examples below:

```bash
make code-format
make code-lint
```

...will run `yapf` and `flake8` on the entire repo and is equivalent to:

```bash
pre-commit run yapf --all-files
pre-commit run flake8 --all-files
```

...and when looking to limit execution to a subset of files do similar to:

```bash
pre-commit run yapf --files trestle_fedramp/*
pre-commit run flake8 --files trestle_fedramp/*
```
