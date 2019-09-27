# Build script by Stanislav Povolotsky (stas.dev<AT>povolotsky.info)
mkdir /tmp/ton-build
cd /tmp/ton-build
mkdir /var/ton/
mkdir /var/ton/bin
mkdir /var/ton/etc

touch /var/ton/src/tonlib/TonlibConfig.cmake
BUILD_STATUS=1

while true; do
  cmake -G "Ninja" $EX_BUILD_ARGS -DCMAKE_INSTALL_PREFIX:PATH=/var/ton --build /var/ton/src
  if [ $? -ne 0 ]; then echo "cmake error"; break; fi

  ninja
  if [ $? -ne 0 ]; then echo "ninja build error"; break; fi

  ninja install
  if [ $? -ne 0 ]; then echo "ninja installation error"; break; fi

  for i in $(find  -executable -type f); do
    cp $i /var/ton/bin/
  done
  rm /var/ton/bin/a.out /var/ton/bin/CMAKE* /var/ton/bin/CMake* 
  #rm /var/ton/bin/test-*

  cp -r /var/ton/src/_sp/etc /var/ton/src/_sp/run /var/ton/
  chmod +x /var/ton/run/*

  # Removing unnecessary files
  rm -rf /var/ton/src/.git >/dev/null 2>&1
  rm -rf /var/ton/src/_sp >/dev/null 2>&1

  # Archiving sources
  tar --remove-files -cvzf /var/ton/ton-blockchain-full.tar.gz /var/ton/src

  BUILD_STATUS=0
  break
done

exit $BUILD_STATUS
