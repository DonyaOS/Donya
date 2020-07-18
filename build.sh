# /bin/bash
# Donya OS
place=$(pwd)

cd $place/pack/busybox-1.32.0
make defconfig
make -j $(nproc)
make install CONFIG_PREFIX=$place/build

cd $place/pack/musl-1.2.0
./configure --prefix=$place/build/usr
make -j $(nproc)
make install

