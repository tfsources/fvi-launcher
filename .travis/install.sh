#! /bin/bash

set -o errexit
set -o nounset

if [[ -z ${QT_VER-} || -z ${TARGET-} ]]; then
  echo "Please define QT_VER and TARGET first"
  exit 1
fi

set -o xtrace


# Native dependencies

if [[ $TARGET = x11* ]]; then
  sudo apt-add-repository -y ppa:brightbox/ruby-ng
  sudo apt-get -qq update
  sudo apt-get install -y \
    libasound-dev \
    libgl1-mesa-dev \	
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-render-util0-dev \
    libxcb-xinerama0-dev \
    libgstreamer-plugins-base1.0-dev \
    libpulse-dev \
    libudev-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libsdl2-dev \
    ruby
  gem install fpm -v 1.10.2
fi

# Install the toolchain

TOOLS_URL=https://github.com/Warfork/fvi-toolchain/raw/master

pushd /tmp
  wget ${TOOLS_URL}/qt${QT_VER//./}_${TARGET}.tar.xz

  if [[ $TARGET == macos* ]]; then OUTDIR=/usr/local; else OUTDIR=/opt; fi
  for f in *.tar.xz; do sudo tar xJf ${f} -C ${OUTDIR}/; done
popd
