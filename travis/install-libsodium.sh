#!/bin/sh
set -e
if [ -f "$HOME/devroot/versions/libsodium${LIBSODIUM_VERSION}" ];
then
  echo "Using cached libsodium ${LIBSODIUM_VERSION}"
else
  echo "Building libsodium ${LIBSODIUM_VERSION}"
  mkdir -p "$HOME/depbuild"
  cd "$HOME/depbuild"
  curl "https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}.tar.gz" -o libsodium.tar.gz
  tar xzf libsodium.tar.gz
  cd "libsodium-${LIBSODIUM_VERSION}"
  ./autogen.sh

  ./configure --prefix="$HOME/devroot" --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
  make
  make install

  mkdir -p "$HOME/devroot/versions"
  touch "$HOME/devroot/versions/libsodium${LIBSODIUM_VERSION}"
fi
