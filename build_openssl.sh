#!/bin/bash -e

cd openssl
INSTALL_DIR="$1"
# openssl configure script will check ANDROID_NDK_ROOT
export ANDROID_NDK_ROOT="$NDK"
# check system is linux or darwin
if [ "$(uname)" == "Darwin" ]; then
    host_tag=darwin-x86_64
else
    host_tag=linux-x86_64
fi
export PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host_tag/bin:$PATH
echo -e "\n\n----- Build openssl (`git describe --tags`) -----"

VERBOSE_FLAGS=""
if [ "$SILENT" == "true" ]; then
	VERBOSE_FLAGS="-s V=0"
	echo "Using non-verbose mode"
fi

# Nov 10, 2021, openssl fix it. https://github.com/openssl/openssl/pull/15086
# now we can use -latomic to fix the build error.
LDFLAGS="-latomic"

echo -e "\n++ Build openssl armeabi-v7a ++"
./Configure no-shared android-arm -D__ANDROID_API__=21 --prefix="$INSTALL_DIR/armeabi-v7a" $LDFLAGS
make $VERBOSE_FLAGS clean
make -j4 $VERBOSE_FLAGS
make install_sw

echo -e "\n++ Build openssl arm64-v8a ++"
./Configure no-shared android-arm64 -D__ANDROID_API__=21 --prefix="$INSTALL_DIR/arm64-v8a" $LDFLAGS
make $VERBOSE_FLAGS clean
make -j4 $VERBOSE_FLAGS
make install_sw

echo -e "\n++ Build openssl x86 ++"
./Configure no-shared android-x86 -D__ANDROID_API__=21 --prefix="$INSTALL_DIR/x86" $LDFLAGS
make $VERBOSE_FLAGS clean
make -j4 $VERBOSE_FLAGS
make install_sw

echo -e "\n++ Build openssl x86_64 ++"
./Configure no-shared android-x86_64 -D__ANDROID_API__=21 --prefix="$INSTALL_DIR/x86_64" $LDFLAGS
make $VERBOSE_FLAGS clean
make -j4 $VERBOSE_FLAGS
make install_sw

cd ..
