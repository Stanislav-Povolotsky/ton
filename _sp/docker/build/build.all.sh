#!/bin/bash
# Build script by Stanislav Povolotsky (stas.dev<AT>povolotsky.info)

OPT_SAVE_SOURCES_ARCHIVE=0
OPT_DISABLE_SSE42=1

SOURCES_FOLDER=/var/ton/src

mkdir /tmp/ton-build
mkdir /var/ton/
mkdir /var/ton/bin
mkdir /var/ton/etc

touch $SOURCES_FOLDER/tonlib/TonlibConfig.cmake

# Archiving sources
if [[ $OPT_SAVE_SOURCES_ARCHIVE != 0 ]]
then
	echo Archiving sources
	cd $SOURCES_FOLDER/
	tar -cvzf /tmp/src.tar.gz .
fi

# Patching sources (to compile not optimized, but CPU-independed code)
if [[ $OPT_DISABLE_SSE42 != 0 ]]
then
	echo Disabling SSE 4.2
	FILES_TO_PATCH="CMakeLists.txt third-party/crc32c/CMakeLists.txt third-party/rocksdb/CMakeLists.txt"
	for cmake_list_file in $FILES_TO_PATCH; do
	    sed -i 's/_mm_crc32_u32/_mm_crc32_u32_always_fail/g' $SOURCES_FOLDER/$cmake_list_file
	done
fi

# Building in this directory
cd /tmp/ton-build

BUILD_STATUS=1

while true; do
  echo Build args: $EX_BUILD_ARGS 1>&2

  cmake -G "Ninja" $EX_BUILD_ARGS -DCMAKE_INSTALL_PREFIX:PATH=/var/ton --build $SOURCES_FOLDER
  if [ $? -ne 0 ]; then echo "cmake error"; break; fi

  ninja
  if [ $? -ne 0 ]; then echo "ninja build error"; break; fi

  ninja install
  if [ $? -ne 0 ]; then echo "ninja installation error"; break; fi

  # Move binaries
  for i in $(find  -executable -type f); do
    mv $i /var/ton/bin/
  done
  rm /var/ton/bin/a.out /var/ton/bin/CMAKE* /var/ton/bin/CMake* 
  #rm /var/ton/bin/test-*

  # Copy required sources
  mv $SOURCES_FOLDER $SOURCES_FOLDER-all
  mkdir -p $SOURCES_FOLDER/crypto/fift/lib
  cp $SOURCES_FOLDER-all/crypto/fift/lib/* $SOURCES_FOLDER/crypto/fift/lib/
  mkdir -p $SOURCES_FOLDER/crypto/smartcont
  cp $SOURCES_FOLDER-all/crypto/smartcont/* $SOURCES_FOLDER/crypto/smartcont/
  mkdir -p $SOURCES_FOLDER/crypto/test/fift
  cp $SOURCES_FOLDER-all/crypto/test/fift/* $SOURCES_FOLDER/crypto/test/fift/

  # Copy "etc" and "run" folders
  cp -r $SOURCES_FOLDER-all/_sp/etc $SOURCES_FOLDER-all/_sp/run /var/ton/
  chmod +x /var/ton/run/*

  # Removing unnecessary files
  rm -rf $SOURCES_FOLDER-all/.git >/dev/null 2>&1
  rm -rf $SOURCES_FOLDER-all/_sp >/dev/null 2>&1

  # Saving sources archive
  if [[ $OPT_SAVE_SOURCES_ARCHIVE != 0 ]]
  then
      cp /tmp/src.tar.gz $SOURCES_FOLDER/
      rm -rf $SOURCES_FOLDER-all/ >/dev/null 2>&1
  fi


  BUILD_STATUS=0
  break
done

exit $BUILD_STATUS