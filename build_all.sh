#!/bin/sh -e

# Submodules should have already been cloned

# Build c-ares
cd c-ares
echo "----- Build c-ares (`git describe --tags`) -----"
autoreconf -i
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64"
cd ..

# Build expat
cd libexpat/expat
echo "----- Build expat (`git describe --tags`) -----"
./buildconf.sh
../../androidbuildlib out_path=../../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64"
cd ../..

# Build zlib
cd zlib
echo "----- Build zlib (`git describe --tags`) -----"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a x86 arm64-v8a x86_64" no_host="true"
cd ..

# Build openssl (android-arm, android-arm64, android-x86, android-x86_64)
cd openssl
PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
echo "----- Build openssl (`git describe --tags`) -----"

echo "++ Build openssl armeabi-v7a ++"
./Configure android-arm -D__ANDROID_API__=21 --prefix=$(pwd)/../libs/armeabi-v7a
make clean
make -j4
make install

echo "++ Build openssl arm64-v8a ++"
./Configure android-arm64 -D__ANDROID_API__=21 --prefix=$(pwd)/../libs/arm64-v8a
make clean
make -j4
make install

echo "++ Build openssl x86 ++"
./Configure android-x86 -D__ANDROID_API__=21 --prefix=$(pwd)/../libs/x86
make clean
make -j4
make install

echo "++ Build openssl x86_64 ++"
./Configure android-x86_64 -D__ANDROID_API__=21 --prefix=$(pwd)/../libs/x86_64
make clean
make -j4
make install

cd ..


# Build libssh2
cd libssh2
echo "----- Build libssh2 (`git describe --tags`) -----"
./buildconf
echo "++ Build openssl armeabi-v7a ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="armeabi-v7a" configure_params="--with-libsslprefix=../libs/armeabi-v7a"

echo "++ Build openssl x86 ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="x86" configure_params="--with-libsslprefix=../libs/x86"

echo "++ Build openssl arm64-v8a ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="arm64-v8a" configure_params="--with-libsslprefix=../libs/arm64-v8a"

echo "++ Build openssl x86_64 ++"
../androidbuildlib out_path=../libs minsdkversion=21 target_abis="x86_64" configure_params="--with-libsslprefix=../libs/x86_64"

cd ..