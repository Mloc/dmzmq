#!/bin/sh
set -e

export PATH=/mingw32/bin:/usr/bin

export LIB_PREFIX=/mingw32

pacman --noconfirm -S unzip

ci/install-byond.sh
ci/install-libsodium.sh
ci/install-libzmq.sh
