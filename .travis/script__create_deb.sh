#! /bin/bash

set -o errexit
set -o nounset
set -o xtrace

SUFFIX=$(git describe --always)_${TARGET}
DEB_REGEX_LATEST='^alpha([0-9]+)-([0-9]+)-g[0-9a-f]+_.*'
DEB_REGEX_STABLE='^alpha([0-9]+)_.*'

if [[ "$SUFFIX" =~ $DEB_REGEX_LATEST ]]; then
  DEB_VER=$(echo $SUFFIX | sed -r "s/${DEB_REGEX_LATEST}/0.\1.\2/")
elif [[ "$SUFFIX" =~ $DEB_REGEX_STABLE ]]; then
  DEB_VER=$(echo $SUFFIX | sed -r "s/${DEB_REGEX_STABLE}/0.\1.0/")
else
  echo "Unrecognized suffix ${SUFFIX}"
  exit 1
fi

fpm -s dir -t deb \
  --name 'fvi-launcher' \
  --version ${DEB_VER} \
  --license 'GPLv3+, Proprietary' \
  --maintainer 'Team Forbidden LLC.' \
  --vendor 'forbidden.gg' \
  --url 'https://forbidden.gg' \
  --category games \
  --deb-compression xz \
  --description "$(printf 'FVI Launcher')" \
  -d 'fontconfig' \
  -d 'gstreamer1.0-plugins-good' \
  -d 'policykit-1' \
  -d 'libsdl2-2.0-0 >= 2.0.4' \
  -d 'libc6 >= 2.25' \
  -d 'libstdc++6 >= 4.8' \
  $PWD/../installoc/=/
