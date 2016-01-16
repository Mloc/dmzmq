#!/bin/sh
set -e
if [ -f "$LIB_PREFIX/versions/libzmq${LIBZMQ_VERSION}" ];
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

  export CPPFLAGS="-I$LIB_PREFIX/include"
  export LDFLAGS="-L$LIB_PREFIX/lib"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LIB_PREFIX/lib"
  export PKG_CONFIG_PATH="$LIB_PREFIX/lib/pkgconfig"

  ./configure --prefix="$LIB_PREFIX"  --host=i686-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
  make install

  mkdir -p "$LIB_PREFIX/versions"
  touch "$LIB_PREFIX/versions/libzmq${LIBZMQ_VERSION}"
fi
