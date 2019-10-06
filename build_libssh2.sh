#!/bin/sh -e

cd libssh2
echo "----- Build libssh2 (`git describe --tags`) -----"
./buildconf

INSTALL_DIR="$1"

echo "++ Build libssh2 armeabi-v7a ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a" configure_params="--with-libssl-prefix=$INSTALL_DIR/armeabi-v7a"

echo "++ Build libssh2 x86 ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="x86" configure_params="--with-libssl-prefix=$INSTALL_DIR/x86"

echo "++ Build libssh2 arm64-v8a ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="arm64-v8a" configure_params="--with-libssl-prefix=$INSTALL_DIR/arm64-v8a"

echo "++ Build libssh2 x86_64 ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="x86_64" configure_params="--with-libssl-prefix=$INSTALL_DIR/x86_64"

cd ..