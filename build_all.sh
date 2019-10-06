#!/bin/bash -e

# Build c-ares
cd c-ares
echo "----- Build c-ares (`git describe --tags`) -----"
autoreconf -i
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64" silent="$SILENT"
cd ..


# Build expat
cd libexpat/expat
echo "----- Build expat (`git describe --tags`) -----"
./buildconf.sh
../../androidbuildlib out_path=../../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64" silent="$SILENT"
cd ../..


# Build zlib
cd zlib
echo "----- Build zlib (`git describe --tags`) -----"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64" no_host="true" silent="$SILENT"
cd ..


# Build openssl 
./build_openssl.sh "$(pwd)/libs"


# Build libssh2
./build_libssh2.sh "$(pwd)/libs"