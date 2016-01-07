#!/bin/sh
set -e
if [ -f "$HOME/devroot/versions/libzmq${LIBZMQ_VERSION}" ];
then
  echo "Using cached libzmq ${libzmq_VERSION}"
else
  echo "Building libzmq ${LIBZMQ_VERSION}"
  mkdir -p "$HOME/depbuild"
  cd "$HOME/depbuild"
  curl "http://download.zeromq.org/zeromq-${LIBZMQ_VERSION}.tar.gz" -o zeromq.tar.gz
  tar xzf zeromq.tar.gz
  cd "zeromq-${LIBZMQ_VERSION}"
  ./autogen.sh

  export CPPFLAGS="-I$HOME/devroot/include"
  export LDFLAGS="-L$HOME/devroot/lib"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/devroot/lib"
  export PKG_CONFIG_PATH="$HOME/devroot/lib/pkgconfig"

  ./configure --prefix="$HOME/devroot"  --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
  make check
  make install

  mkdir -p "$HOME/devroot/versions"
  touch "$HOME/devroot/versions/libzmq${LIBZMQ_VERSION}"
fi
