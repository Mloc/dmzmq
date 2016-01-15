#!/bin/sh
set -e
if [ -f "$1/versions/libzmq${LIBZMQ_VERSION}" ];
then
  echo "Using cached libzmq ${LIBZMQ_VERSION}"
else
  echo "Building libzmq ${LIBZMQ_VERSION}"
  mkdir -p "$HOME/depbuild"
  cp ci/libzmq-msys2.patch "$HOME/depbuild"
  cd "$HOME/depbuild"
  curl "http://download.zeromq.org/zeromq-${LIBZMQ_VERSION}.tar.gz" -o zeromq.tar.gz
  tar xzf zeromq.tar.gz
  cd "zeromq-${LIBZMQ_VERSION}"
  patch -p1 < ../libzmq-msys2.patch
  ./autogen.sh

  export CPPFLAGS="-I$1/include"
  export LDFLAGS="-L$1/lib"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$1/lib"
  export PKG_CONFIG_PATH="$1/lib/pkgconfig"

  ./configure --prefix="$1"  --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
  make check
  make install

  mkdir -p "$1/versions"
  touch "$1/versions/libzmq${LIBZMQ_VERSION}"
fi
