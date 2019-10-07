#!/bin/bash -e

# Check NDK and ANDROID_NDK_HOME env
if [ -z "$NDK" ]; then
	if [ -z "$ANDROID_NDK_HOME" ]; then
    	echo 'No $NDK or $ANDROID_NDK_HOME specified.'
    	exit 1
    else
    	export NDK="$ANDROID_NDK_HOME"
    fi
else
	export ANDROID_NDK_HOME="$NDK"
fi


# Clean
rm -rf libs
rm -rf bin


# Build c-ares
cd c-ares
echo "----- Build c-ares (`git describe --tags`) -----"
autoreconf -i
../androidbuildlib out_path=../libs minsdkversion=21 \
	target_abis="armeabi-v7a x86 arm64-v8a x86_64" \
	silent="$SILENT" custom_silent="--silent" \
	configure_params="--disable-shared --enable-static"
cd ..


# Build expat
cd libexpat/expat
echo -e "\n\n----- Build expat (`git describe --tags`) -----"
./buildconf.sh
../../androidbuildlib out_path=../../libs minsdkversion=21 \
	target_abis="armeabi-v7a x86 arm64-v8a x86_64" \
	silent="$SILENT" \
	configure_params="--disable-shared --enable-static"
cd ../..


# Build zlib
cd zlib
echo -e "\n\n----- Build zlib (`git describe --tags`) -----"
../androidbuildlib out_path=../libs minsdkversion=21 \
	target_abis="armeabi-v7a x86 arm64-v8a x86_64" \
	no_host="true" \
	silent="$SILENT" custom_silent="" \
	configure_params="--static"
cd ..


# Build openssl 
./build_openssl.sh "$(pwd)/libs"


# Build libssh2
./build_libssh2.sh "$(pwd)/libs"


# Build aria2
./build_aria2.sh minsdkversion=21 \
	target_abis="armeabi-v7a x86 arm64-v8a x86_64" \
	silent="$SILENT"