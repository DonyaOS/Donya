
############################################################################################

# DonyaOS script

############################################################################################


############################################################################################
#Initialization 
############################################################################################


# !/bin/bash

base_dir=`pwd`


## Create directories
mkdir -p ${base_dir}/packages
mkdir -p ${base_dir}/extracted
mkdir -p ${base_dir}/iso


############################################################################################
############################################################################################



####################################################################################
#call downloader script 
#download_package.sh
####################################################################################

# wget https://kernel.org/pub/linux/kernel/v5.x/linux-5.8.tar.xz
# wget http://busybox.net/downloads/busybox-1.32.0.tar.bz2
# wget http://kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz


############################################################################################
#Extract
#extract compressed packages and place on appropriate directory
############################################################################################


# busybox
mkdir -p ${base_dir}/extracted/busybox
tar -xvf ${base_dir}/packages/busybox-1.32.0.tar.bz2 -C ${base_dir}/extracted/busybox

# linux
mkdir -p ${base_dir}/extracted/linux
tar -xvf ${base_dir}/packages/linux-5.8.tar.xz -C ${base_dir}/extracted/linux

# syslinux
mkdir -p ${base_dir}/extracted/syslinux
tar -xvf ${base_dir}/packages/syslinux-6.03.tar.xz -C ${base_dir}/extracted/syslinux


############################################################################################
############################################################################################




############################################################################################
#Compile
#Compile extracted packages
############################################################################################


echo "compiling busybox"

cd ${base_dir}/extracted/busybox/*

make distclean
make defconfig

sed -i "s|.*CONFIG_STATIC.*|CONFIG_STATIC=y|" .config

make busybox

make install
echo "Finish compiling busybox"


############################################################################################
############################################################################################


############################################################################################
## Create rootfs.gz
############################################################################################


echo "generate rootfs"

cd _install
rm -f linuxrc

mkdir -p dev proc sys

echo '#!/bin/sh' > init
echo 'dmesg -n 1' >> init
echo 'mount -t devtmpfs none /dev' >> init
echo 'mount -t proc none /proc' >> init
echo 'mount -t sysfs none /sys' >> init
echo 'setsid cttyhack /bin/sh' >> init

chmod +x init

find . | cpio -R root:root -H newc -o | gzip > ${base_dir}/iso/rootfs.gz

echo "rootfs generation finished..."


############################################################################################
############################################################################################




##########################################################################
### Compile linux
##########################################################################


echo "########Compile linux##########"

cd ${base_dir}/extracted

cd linux/*

# How to speedup compilation?

# # cpu_cores=awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo
# # -j${cpu_cores}
# #

make -j4 mrproper defconfig bzImage

cp arch/x86/boot/bzImage ${base_dir}/iso/kernel.gz

echo "########## finished ##########"

############################################################################################
############################################################################################


############################################################################################
#generate isolinux.cfg
############################################################################################


echo "########## busybox, create isolinux.cfg ##########"

cp ${base_dir}/extracted/syslinux/*/bios/core/isolinux.bin ${base_dir}/iso/
cp ${base_dir}/extracted/syslinux/*/bios/com32/elflink/ldlinux/ldlinux.c32 ${base_dir}/iso/

echo 'default kernel.gz initrd=rootfs.gz' > ${base_dir}/iso/isolinux.cfg

echo "########## Finsihed ##########"


############################################################################################
############################################################################################



############################################################################################
#Generate iso
############################################################################################


cd ${base_dir}/iso

echo "########## Make iso ##########"

xorriso \
    -as mkisofs \
    -o ${base_dir}/donyaOS.iso \
    -b isolinux.bin \
    -c boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    ./    


############################################################################################
############################################################################################



############################################################################################
############################################################################################


echo "########## Process finished ##########"
echo "########## donyaOS ready to use ##########"


############################################################################################
############################################################################################



