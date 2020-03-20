#! /bin/bash

set -o errexit
set -o nounset
set -o xtrace

git submodule sync
git submodule update --init --recursive

mkdir dist


TOOLS_URL=https://github.com/Warfork/fvi-toolchain/raw/master
curl -L ${TOOLS_URL}/${QT_VERSION}_${QT_TARGET}.txz | tar xJf - -C /opt/
