# CHANGELOG



## v0.4.0 (2024-09-25)

### Chore

* chore: Merge back version tags and changelog into develop. ([`fa1b53d`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/fa1b53da7b4e239165c9e32a1c4909140cb1d0cb))

### Feature

* feat: adds fedramp-transform command implementation (#39)

This changes adds the initial implementation for populating
FedRAMP document templates with information from OSCAL SSPs with
FedRAMP extensions

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`2136659`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/213665951cd3e80de3c3baf26a1f982551c7c7db))

### Unknown

* Merge pull request #57 from oscal-compass/develop

chore: fedramp plugin release ([`73522ca`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/73522ca3dcd7a8d41ebc0a1c01a874d6e74f31f1))


## v0.3.0 (2024-09-16)

### Breaking

* feat: updates content and git submodule for FedRAMP Rev5 validation (#22)

* feat: updates content from FedRAMP Rev4 to Rev5

Updates FedRAMP submodule to the latest commit

The location of the XSLT has changed from the repository to the OSCAL
release so the NIST submodule was removed and the download_oscal_converters
script was added

BREAKING CHANGE: This drops support for Rev4 validation

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* test: adds assertions to validate command unit tests

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`d09c742`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/d09c74287463339ddf10fc5805dec8c043286175))

### Build

* build(deps): bump actions/checkout from 2 to 4 (#51)

Bumps [actions/checkout](https://github.com/actions/checkout) from 2 to 4.
- [Release notes](https://github.com/actions/checkout/releases)
- [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
- [Commits](https://github.com/actions/checkout/compare/v2...v4)

---
updated-dependencies:
- dependency-name: actions/checkout
  dependency-type: direct:production
  update-type: version-update:semver-major
...

Signed-off-by: dependabot[bot] &lt;support@github.com&gt;
Co-authored-by: dependabot[bot] &lt;49699333+dependabot[bot]@users.noreply.github.com&gt; ([`ba4e976`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/ba4e976fb2ca1ebf2e5eefa60d4a228c565b7dea))

### Chore

* chore(deps): bump trestle version to major version 3 (#44)

* chore(deps): updates trestle to new major version

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore(deps): drops python 3.8 support, adds 3.10 and 3.11

Aligns supported python versions with compliance-trestle

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: replaces pkg_resources with importlib.resources

pkg_resources is deprecated in Python 3.11

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`b16607d`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/b16607d43024d98f29f6d0c4671f9422e2fe9577))

* chore: Merge back version tags and changelog into develop. ([`7b6cc41`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/7b6cc418a7c72273a8581783204ea666c8f30049))

* chore: add updates information for move to new org (#35)

* docs: updates README and setup.cfg with new organization

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* docs: updates CODE OF CONDUCT to match compliance-trestle

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* docs: updates issue templates with new organization and repo information

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* ci: updates workflow files with correct organization information

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* docs: updates MAINTAINER.md

* docs: updates CONTRIBUTING.md with trestle guidance

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* docs: fixes grammatical errors in contributing doc

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`9556b6d`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/9556b6d43edd947f458776e435e040d08124e815))

* chore: updates actions on the python-push.yml (#30)

* chore: removes windows dev tool install from python-push.yml

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: removes direct-merge-action from python-push.yml

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* ci: removes sonar job and combines lint and test into build

This alter the CI Trestle Deploy workflow to match the
compliance-trestle workflow

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`bffa6ed`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/bffa6ed6170f6651c8812b327806386a9a0f9c23))

* chore: Merge back version tags and changelog into develop. ([`4420c46`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/4420c46585d755e618749abb78fb05fa724584a2))

### Ci

* ci: updates github actions and adds dependabot configuration (#49)

* build(deps): updates GitHub Actions versions in CI
* feat: adds dependabot for automated updates

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`623f787`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/623f7871aa0deed0d614354046f1439f368155d3))

* ci: updates workflow for v9 of semantic release (#46)

* fix: pins semantic release to version v7 and adds an optional minor flag

The latest version of semantic-release does not support setup.cfg.
Pinning to the same version as compliance-trestle so the upgrades
can be made in sync. This project is still in beta so adding an option
to force minor releases for breaking changes.

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: fixes formatting on Makefile

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: set MINOR variable on python-push.yml

* refactor: updates semantic release to 9.8.0

Align semantic release update logic with trestle

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: moves MINOR env logic from Makefile

This is handled through pyproject.toml

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* ci(deps): updates actions/checkout to v4 in python-push workflow

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`7a5ec63`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/7a5ec636c7e7290a81a704329a315a93aeb03253))

* ci: adds commitlint configuration for CI PR linting check (#24)

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`3c8ed8c`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/3c8ed8c370003e173dbf381392c9abf1befdc73a))

### Documentation

* docs: updates CODE_OF_CONDUCT to CNCF (#45)

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`d95a894`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/d95a894b1133fd433c4e68c117c5d57a2428e85d))

* docs: updates README with fixed linked and setup information (#26)

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`3bb0291`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/3bb0291ae2f28f3bac08f07b52a135d395072036))

### Feature

* feat: updates python dependencies for fedramp plugin (#21)

* feat: update to use trestle version 2

Update trestle to version 2.5.1
Adds initial code changes for trestle v2 API
Updates pre-commit configuration

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* feat: Remove saxonc configuration

Signed-off-by: Ekaterina Nikonova &lt;Ekaterina.Nikonova@ibm.com&gt;

* feat: updates project to use saxonc-he version 12.4.1

Official python wheel packages are available for
saxonc home edition. This updates the code and setup config to
use that version.

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: removes pre-commit autoupdate from code-format and code-lint

The autoupdate feature is updating flake8 to a version that does not support Python 3.8

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: drops python 3.7 support

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* chore: fixes linting errors

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

* ci: updates Actions in CI workflow to match compliance-trestle

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;

---------

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt;
Signed-off-by: Ekaterina Nikonova &lt;Ekaterina.Nikonova@ibm.com&gt;
Co-authored-by: Ekaterina Nikonova &lt;Ekaterina.Nikonova@ibm.com&gt; ([`675f354`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/675f354b3ea9bc63434a43ce9338da1b856704e0))

### Fix

* fix: updates build command to install deps into container (#55)

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`868716f`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/868716f5b0da48062d79f712e217edcdf5f37b7e))

* fix: updates sonar job so it does not run on dependabot PRs (#53)

Signed-off-by: Jennifer Power &lt;barnabei.jennifer@gmail.com&gt; ([`daf39af`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/daf39af9e753cc92bb39f4403952a47bfd45df89))

* fix: add submodules update in Makefile (#18)

* fix: model extension

* fix: added submdules in Makefile

* fix: added toml dependency

Co-authored-by: Vikas &lt;avikas@in.ibm.com&gt; ([`278c994`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/278c99474d12472ba78b2b2fdadedb2feb35beaa))

### Unknown

* Merge pull request #56 from oscal-compass/develop

chore: fedramp release ([`23debac`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/23debac1d6ae96e29ee4580691c293227a1a4059))

* Merge pull request #48 from oscal-compass/develop

chore: fedramp plugin release ([`1186c6a`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/1186c6a0eac2362dea4a44bca16d73499a00b3f1))

* Merge pull request #31 from oscal-compass/develop

chore: fedramp plugin release ([`0b78f39`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/0b78f395923d62440b77fd40e5c23598cf0e650c))

* Merge pull request #28 from IBM/develop

chore: fedramp plugin release ([`b2f3e21`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/b2f3e21f480f176b0edfda9cc03284c4faaf48ed))


## v0.2.1 (2021-12-22)

### Chore

* chore: Merge back version tags and changelog into develop. ([`9f7e3b3`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/9f7e3b36722561caaf9b454793d2c0d50a4010a9))

### Fix

* fix: updated readme.md (#10)

* fix: model extension

* fix: updated readme.md

* fix: updated mdformatting

Co-authored-by: Vikas &lt;avikas@in.ibm.com&gt; ([`5ad08fa`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/5ad08faf0ce212e1d7926e5e12df4913e6fba873))

### Unknown

* Merge pull request #11 from IBM/develop

chore: release ([`78744fa`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/78744fa83b06f7a317272bf3d0d11b70bbfb5b71))


## v0.2.0 (2021-12-03)

### Chore

* chore: Merge back version tags and changelog into develop. ([`16e766c`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/16e766c79d44ae7643767ece9cca655b62b13d08))

### Feature

* feat: added fedramp validation code (#2)

* added fedramp validation code

* corrected format and lint

* fix: Correcting build scripts to allow saxon installs.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correcting CI workflow.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correcting CI workflow.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correcting CI workflow.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correct environment for linux

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correct environment for linux

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: setting up environment correctly across mac os and linux.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Added missing install script.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Test for ubuntu latest only.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: remove more build options.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Add extra test verbosity

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Ensure libraries have permission to copy.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Ensure libraries have permission to copy.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Correct mac os build path

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Correct mac os build path

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Stuff

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Stuff

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Get it done.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Fix paths.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Fix paths.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* added command and updated saxonc install on MacOS

* updated code linting

* updated saxonc install on MacOS

* fix: update macos script

* fix: macos sxcript

* fix: macos

* fix: macos script

* fix macos

* fix: Ensure saxon is available to bdist testing

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Ensure saxon is available to bdist testing

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Much more logging in the test script

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: ensure explicit export of of environmental variables.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: ensure explicit export of of environmental variables.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Checking github env.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Checking github env.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Checking github env.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Envirnonmental variables passing.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Remove uneeded if statement.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: Checking pythonpath.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correct source.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correct source.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

* fix: correct source.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt;

Co-authored-by: Vikas &lt;avikas@in.ibm.com&gt;
Co-authored-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`1c365ab`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/1c365abacd95f38490966e399dc7e868aeedb076))

### Fix

* fix: fedramp validate command to extend from CommandBase (#8)

* fix: model extension

* fix: updated command to use CommandBase instead of CommandPlusDocs

* fix: update code formatting

* fix: update setup for right trestle version

Co-authored-by: Vikas &lt;avikas@in.ibm.com&gt; ([`caf61ae`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/caf61aeefca536510b95b8377b1314ee0792392e))

* fix: Correct build pipeline for prod (#7)

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`533fda9`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/533fda909103c65ec0e0709b844eeed9eb45d66d))

* fix: model extension (#5)

Co-authored-by: Vikas &lt;avikas@in.ibm.com&gt; ([`1c20dd5`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/1c20dd5c824cadeb5b36aa8fbad6bba2b4430dc8))

### Unknown

* Merge pull request #9 from IBM/develop

chore: trestle-fedramp release ([`5e84457`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/5e8445728c481a6bc567faf7f3b12130e72f894f))

* Merge pull request #6 from IBM/develop

chore: Trestle fedramp release ([`b62633b`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/b62633b7c62b2eb80adfd8666a38f1ef5bb5c910))


## v0.1.0 (2021-11-11)

### Feature

* feat: Add changelog marker for semantic release.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`8905afd`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/8905afd00493124ed5f32c79966a87cdf568ae48))

* feat: Initial CI setup.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`6271821`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/62718215d45a5f07e1a07395077c27a486e924e3))

### Fix

* fix: Setting floor coverage to 0

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`d32cac4`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/d32cac48f7dc47fe98ffb303ba56bdf4fb00c34a))

* fix: Correcting PR  linting pipeline

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`0600f2a`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/0600f2ac046eba518f9c0a0c9c67eeb2a6f9ab2a))

* fix: Adding bdist test scripts.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`f84e1bf`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/f84e1bf42c1051a10f403b675ccd001b74723b2e))

* fix: Correcting mdformat.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`f3b8c18`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/f3b8c18619201889137683113f0b6ff4055b09d5))

### Unknown

* Merge pull request #4 from IBM/develop

Test release ([`e8fa012`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/e8fa01271d948fd2cf01492be60ec008f2de5daa))

* Merge pull request #3 from IBM/feat/CI

chore: Ensuring CI is setup correctly. ([`58ade78`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/58ade780ec6d0c93eccb66a0f21cd8061d581daa))

* Chore: Ensuring CI is setup correctly.

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`68b7c97`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/68b7c970d4ecb06742a7100544f23cbf7f85cc73))

* Merge pull request #1 from IBM/feat/initial_ci_setup

feat: Initial CI setup. ([`af66c86`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/af66c8658ab55cade616a1486991a28c5f015992))

* fix:Updating sonar setup

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`cfb6f37`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/cfb6f37213ee7723d617b7bf5e7bd7d07fdd156a))

* fix:Updating sonar setup

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`2a3131d`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/2a3131deb4bfb8de1eaba6376ea8ed1849e80282))

* fix:Cleaned up CI pipelines

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`32f0b0a`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/32f0b0a56bc9c5dc8012722d3a940ab8b0f72238))

* fix:Cleaned up CI pipelines

Signed-off-by: Chris Butler &lt;chris@thebutlers.me&gt; ([`56c5c5e`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/56c5c5e85ffd554b121f722b693210be91c5fe41))

* Initial commit ([`44298fe`](https://github.com/oscal-compass/compliance-trestle-fedramp/commit/44298fef983ecb1ba0500b2ddd043de43872eae0))
