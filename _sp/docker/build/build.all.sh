# Build script by Stanislav Povolotsky (stas.dev<AT>povolotsky.info)
mkdir /tmp/ton-build
cd /tmp/ton-build
mkdir /var/ton/
mkdir /var/ton/bin
mkdir /var/ton/etc
mkdir /var/ton/crypto

touch /var/ton/src/tonlib/TonlibConfig.cmake
BUILD_STATUS=1

while true; do
  echo Build args: $EX_BUILD_ARGS 1>&2

  cmake -G "Ninja" $EX_BUILD_ARGS -DCMAKE_INSTALL_PREFIX:PATH=/var/ton --build /var/ton/src
  if [ $? -ne 0 ]; then echo "cmake error"; break; fi

  ninja
  if [ $? -ne 0 ]; then echo "ninja build error"; break; fi

  ninja install
  if [ $? -ne 0 ]; then echo "ninja installation error"; break; fi

  # Copy binaries
  for i in $(find  -executable -type f); do
    cp $i /var/ton/bin/
  done
  rm /var/ton/bin/a.out /var/ton/bin/CMAKE* /var/ton/bin/CMake* 
  #rm /var/ton/bin/test-*

  # Copy required sources
  mv /var/ton/src /var/ton/src-all
  mkdir -p /var/ton/src/crypto/fift/lib
  cp /var/ton/src-all/crypto/fift/lib/* /var/ton/src/crypto/fift/lib/
  mkdir -p /var/ton/src/crypto/smartcont
  cp /var/ton/src/crypto/smartcont/* /var/ton/src/crypto/smartcont/
  mkdir -p /var/ton/src/crypto/test/fift
  cp /var/ton/src/crypto/test/fift* /var/ton/src/crypto/test/fift/

  # Archiving sources
  pushd /var/ton/src-all/
  tar -cvzf /var/ton/src/src.tar.gz ./
  popd
  rm -rf /var/ton/src-all/ >/dev/null 2>&1

  cp -r /var/ton/src/_sp/etc /var/ton/src/_sp/run /var/ton/
  chmod +x /var/ton/run/*

  # Removing unnecessary files
  rm -rf /var/ton/src/.git >/dev/null 2>&1
  rm -rf /var/ton/src/_sp >/dev/null 2>&1


  BUILD_STATUS=0
  break
done

exit $BUILD_STATUS