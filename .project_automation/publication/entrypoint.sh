#!/bin/bash -ex

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "[STAGE: Publication]"
VERSION=$(cat VERSION)
echo $VERSION
BRANCH=main
EXISTING_GIT_VERSION="$(git tag -l)"

if [[ $(echo $EXISTING_GIT_VERSION | grep $VERSION) ]]
then
  echo "version exists skipping release creation hint: Bump version in VERSION file"
else
  echo "creating new version"
  gh release create ${VERSION} --target ${BRANCH} --generate-notes
fi
