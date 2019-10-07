#!/bin/bash -e

cd libssh2
echo -e "\n\n----- Build libssh2 (`git describe --tags`) -----"
./buildconf

INSTALL_DIR="$1"

echo -e "\n++ Build libssh2 armeabi-v7a ++"
../androidbuildlib out_path=../libs \
	minsdkversion=21 \
	target_abis="armeabi-v7a" \
	configure_params="--disable-shared --enable-static --with-libssl-prefix=$INSTALL_DIR/armeabi-v7a" \
	silent="$SILENT" custom_silent="--silent"

echo -e "\n++ Build libssh2 x86 ++"
../androidbuildlib out_path=../libs \
	minsdkversion=21 \
	target_abis="x86" \
	configure_params="--disable-shared --enable-static --with-libssl-prefix=$INSTALL_DIR/x86" \
	silent="$SILENT" custom_silent="--silent"

echo -e "\n++ Build libssh2 arm64-v8a ++"
../androidbuildlib out_path=../libs \
	minsdkversion=21 \
	target_abis="arm64-v8a" \
	configure_params="--disable-shared --enable-static --with-libssl-prefix=$INSTALL_DIR/arm64-v8a" \
	silent="$SILENT" custom_silent="--silent"

echo -e "\n++ Build libssh2 x86_64 ++"
../androidbuildlib out_path=../libs \
	minsdkversion=21 \
	target_abis="x86_64" \
	configure_params="--disable-shared --enable-static --with-libssl-prefix=$INSTALL_DIR/x86_64" \
	silent="$SILENT" custom_silent="--silent"

cd ..