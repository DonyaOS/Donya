# /bin/bash
# Donya OS
place=$(pwd)

cd $place/pack/linux-5.7.9
make defconfig
make -j $(nproc)

