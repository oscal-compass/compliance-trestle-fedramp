#!/bin/bash

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

# download_oscal_converters.sh
# Download OSCAL XML to JSON converters from the OSCAL GitHub repo


if [ -z "$1" ]; then
    echo "Please provide a tag name for the OSCAL release"
    exit 1
fi

if [ -z "$2" ]; then
    directory="oscal-converters"
else
    directory="$2"
fi

echo "Downloading OSCAL converters from release $1 to $directory"

# Create the directory if it doesn't exist
mkdir -p "$directory"
pushd ./"$directory" || exit 1

# Store the long command in another variable to make it easier to read
oscal_release_url="https://api.github.com/repos/usnistgov/OSCAL/releases/tags/${1}"
assets_url=$(curl -sL "$oscal_release_url" | jq -r '.assets[] | select(.name | test("oscal_.*_json-to-xml-converter.xsl")) | .browser_download_url')
mapfile -t release_artifacts < <(echo "$assets_url")

for asset_url in "${release_artifacts[@]}"; do \
        echo "Downloading $asset_url..."; \
        curl -sLJO "$asset_url"; \
done

popd || exit 1