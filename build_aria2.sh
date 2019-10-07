#!/bin/bash -e


LIBS_DIR=$(pwd)/libs
INSTALL_DIR=$(pwd)/bin
mkdir -p $INSTALL_DIR

cd aria2
echo -e "\n\n----- Build aria2 (`git describe --tags`) -----"

autoreconf -i


print_help()
{
  __text="
Configurable parameters
   host_tag          - host value that will build the library (hint: you can take a look for this value
                       at your \$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/ [default is linux-x86_64]
   minsdkversion     - minimum sdk version to support, this is value of api level [default is 18]
   target_abis       - target abis to build for, separated by space [default is \"armeabi-v7a x86 arm64-v8a x86_64\"]
   silent            - whether the compilation should be less verbose
   strip             - whether the binaries should be stripped [default is true]
"
  echo "$__text"
}

# print help
if [ "$1" == "--help" ]
then
  print_help
  exit
fi

# check for existence of configure, and Makefile
if [ ! -e configure ] && { [ ! -e Makefile ] || [ ! -e makefile ]; }
then
  echo "Cannot find either configure or Makefile file"
  exit 1
fi

host_tag=linux-x86_64
minsdkversion=18
target_abis="armeabi-v7a x86 arm64-v8a x86_64"
silent=false
strip=true

for ARGUMENT in "$@"
do
  KEY=$(echo $ARGUMENT | cut -f1 -d=)
  VALUE=$(echo $ARGUMENT | cut -f2- -d=)

  case "$KEY" in
    "host_tag" ) host_tag="${VALUE}" ;;
    "minsdkversion" ) minsdkversion="${VALUE}" ;;
    "target_abis" ) target_abis="${VALUE}" ;;
    "silent" ) silent="${VALUE}" ;;
    "strip" ) strip="${VALUE}" ;;
    *)
      echo ""
      echo "Unknown '$KEY' parameter"
      print_help
      exit 1
      ;;
  esac
done

echo ""
echo "-Will use following setting-"
echo "host_tag           = $host_tag"
echo "minsdkversion      = $minsdkversion"
echo "target_abis        = $target_abis"
echo "silent             = $silent"
echo ""

export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$host_tag


for target in $target_abis
do
  if [ $target == "armeabi-v7a" ]
  then
    echo "prepare for armeabi-v7a"
    cc_prefix=armv7a-linux-androideabi$minsdkversion-
    support_prefix=arm-linux-androideabi-
    host=armv7a-linux-androideabi
    install_dir=$INSTALL_DIR/armeabi-v7a
    CFLAGS="${CFLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb"
  elif [ $target == "x86" ]
  then
    echo "prepare for x86"
    cc_prefix=i686-linux-android$minsdkversion-
    support_prefix=i686-linux-android-
    host=i686-linux-android
    install_dir=$INSTALL_DIR/x86
    CFLAGS="${CFLAGS} -march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"
  elif [ $target == "arm64-v8a" ]
  then
    echo "prepare for arm64-v8a"
    cc_prefix=aarch64-linux-android$minsdkversion-
    support_prefix=aarch64-linux-android-
    host=aarch64-linux-android
    install_dir=$INSTALL_DIR/arm64-v8a
  else
    echo "prepare for x86_64"
    cc_prefix=x86_64-linux-android$minsdkversion-
    support_prefix=x86_64-linux-android-
    host=x86_64-linux-android
    install_dir=$INSTALL_DIR/x86_64
    CFLAGS="${CFLAGS} -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel"
  fi
  
  echo ""
  echo "cc_prefix           = $cc_prefix"
  echo "support_prefix      = $support_prefix"
  echo "host                = $host"
  echo "install_dir         = $install_dir"
  echo "CFLAGS              = $CFLAGS"
  echo ""
  
  export AR=$TOOLCHAIN/bin/${support_prefix}ar
  export AS=$TOOLCHAIN/bin/${support_prefix}as
  export CC=$TOOLCHAIN/bin/${cc_prefix}clang
  export CXX=$TOOLCHAIN/bin/${cc_prefix}clang++
  export LD=$TOOLCHAIN/bin/${support_prefix}ld
  export RANLIB=$TOOLCHAIN/bin/${support_prefix}ranlib
  export STRIP=$TOOLCHAIN/bin/${support_prefix}strip

  configure_params=""
  make_params=""
  if [ "$silent" == "true" ]; then 
    make_params="-s V=0"
    configure_params="--silent"
  fi

  LIBS_TARGET_DIR=$LIBS_DIR/$target

  ./configure \
    --host="$host" \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    --prefix="$install_dir" \
    --disable-nls \
    --without-gnutls \
    --with-openssl \
    --without-sqlite3 \
    --without-libxml2 \
    --with-libexpat \
    --with-libcares \
    --with-libz \
    --with-libssh2 \
    $configure_params \
    CXXFLAGS="-Os -g" \
    CFLAGS="-Os -g" \
    CPPFLAGS="-fPIE" \
    LDFLAGS="-fPIE -pie -L$LIBS_TARGET_DIR/lib -static-libstdc++" \
    PKG_CONFIG_LIBDIR="$LIBS_TARGET_DIR/lib/pkgconfig" || exit

    
  make $make_params clean || exit
  make -j4 $make_params || exit
  make install || exit

  if [ "$strip" == "true" ]; then
    $STRIP $install_dir/bin/aria2c
  fi

  echo "Done building $target"
done

echo "All done"
