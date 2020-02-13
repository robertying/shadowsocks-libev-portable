#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BUILD_DIR=$DIR/build
mkdir -p $BUILD_DIR
cd $BUILD_DIR

CPU=2

pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-libsodium mingw-w64-x86_64-mbedtls mingw-w64-x86_64-pcre mingw-w64-x86_64-c-ares git

GCC_PATH=$(which gcc)
MINGW64_BIN=${GCC_PATH::-4}

git clone https://github.com/shadowsocks/shadowsocks-libev
cd shadowsocks-libev
git submodule init && git submodule update

ver=4.31
wget http://dist.schmorp.de/libev/libev-$ver.tar.gz
tar zxf libev-$ver.tar.gz
cd libev-$ver
./configure --prefix=$BUILD_DIR/libev --disable-shared
LDFLAGS=-static make -j$CPU
make install
cd ..

./autogen.sh
./configure --prefix=$BUILD_DIR/shadowsocks-libev --disable-documentation \
--with-ev=$BUILD_DIR/libev
make -j$CPU && make install
cd ..

cd ..

cp $MINGW64_BIN/libwinpthread-1.dll $BUILD_DIR/shadowsocks-libev/bin/
cp $MINGW64_BIN/libmbedcrypto.dll $BUILD_DIR/shadowsocks-libev/bin/
cp $MINGW64_BIN/libssp-0.dll $BUILD_DIR/shadowsocks-libev/bin/
cp $MINGW64_BIN/libpcre-1.dll $BUILD_DIR/shadowsocks-libev/bin/
cp $MINGW64_BIN/libsodium-23.dll $BUILD_DIR/shadowsocks-libev/bin/
cp $MINGW64_BIN/libgcc_s_seh-1.dll $BUILD_DIR/shadowsocks-libev/bin/

tar czf shadowsocks-libev-windows.tar.gz $BUILD_DIR/shadowsocks-libev/bin -C $BUILD_DIR/shadowsocks-libev .
