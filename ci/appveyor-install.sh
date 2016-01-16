#!/bin/sh
set -e

export LIB_PREFIX=/mingw32

export BYOND_MAJOR=$1
export BYOND_MINOR=$2
export LIBSODIUM_VERSION=$3
export LIBZMQ_VERSION=$4

pacman -S --noconfirm p7zip
alias unzip='7z e'

ci/install-byond.sh
ci/install-libsodium.sh
ci/install-libzmq.sh
