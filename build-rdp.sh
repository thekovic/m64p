#!/usr/bin/env bash

set -e

UNAME=$(uname -s)
if [[ $UNAME == *"MINGW"* ]]; then
  suffix=".dll"
  if [[ $UNAME == *"MINGW64"* ]]; then
    mingw_prefix="mingw64"
  else
    mingw_prefix="mingw32"
  fi
elif [[ $UNAME == *"Darwin"* ]]; then
  suffix=".dylib"
  qt_version=$(ls /usr/local/Cellar/qt@5)
  export CXXFLAGS='-stdlib=libc++'
  export LDFLAGS='-mmacosx-version-min=10.7'
else
  suffix=".so"
fi

export NEW_DYNAREC=1

install_dir=$PWD/mupen64plus
mkdir -p $install_dir
base_dir=$PWD

mkdir -p $base_dir/parallel-rdp-standalone/build
cd $base_dir/parallel-rdp-standalone/build
if [[ $UNAME == *"MINGW"* ]]; then
  cmake -G "MSYS Makefiles" -DCMAKE_BUILD_TYPE=Release ..
else
  cmake -DCMAKE_BUILD_TYPE=Release ..
fi
cmake --build .
cp mupen64plus-video-parallel.* $install_dir

if [[ "$1" != "nozip" ]]; then
  if [[ $UNAME != *"Darwin"* ]]; then
    cd $base_dir
    rm -f $base_dir/*.zip
    HASH=$(git rev-parse --short HEAD)
    zip -r rdp-$my_os-$HASH.zip mupen64plus
  fi
fi
