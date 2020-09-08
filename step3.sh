
#3. Building the Target Image

# The hard part is now complete—you have the cross compiler. Now, let's focus on building the components that will be installed on the target image. This includes various libraries and utilities and, of course, the Linux kernel itself. 


# BusyBox

# Uncompress the tarball and change into its directory. Then load the default compilation configuration template: 


cd "$base_dir/extracted" || exit 1

cd busybox*

make CROSS_COMPILE="${LJOS_TARGET}-" defconfig

make CROSS_COMPILE="${LJOS_TARGET}-"
make CROSS_COMPILE="${LJOS_TARGET}-" CONFIG_PREFIX="${LJOS}" install


# Install the following Perl script, as you'll need it for the kernel build below:

cp -v examples/depmod.pl ${LJOS}/cross-tools/bin
chmod 755 ${LJOS}/cross-tools/bin/depmod.pl




## The Linux Kernel

# Change into the kernel package directory and run the following to set the default x86-64 configuration template: 

cd "$base_dir/extracted" || exit 1

cd linux*


make ARCH=${LJOS_ARCH} \
CROSS_COMPILE=${LJOS_TARGET}- x86_64_defconfig


make ARCH=${LJOS_ARCH} CROSS_COMPILE=${LJOS_TARGET}-

make ARCH=${LJOS_ARCH} CROSS_COMPILE=${LJOS_TARGET}- \
INSTALL_MOD_PATH=${LJOS} modules_install


# You'll need to copy a few files into the /boot directory for GRUB:

cp -v arch/x86/boot/bzImage ${LJOS}/boot/vmlinuz-5.8.0
cp -v System.map ${LJOS}/boot/System.map-5.8.0
cp -v .config ${LJOS}/boot/config-5.8.0


# Then run the previously installed Perl script provided by the BusyBox package:

${LJOS}/cross-tools/bin/depmod.pl \
-F ${LJOS}/boot/System.map-5.8.0 \
-b ${LJOS}/lib/modules/5.8.0

#####################################################################################




# The Bootscripts 

cd "$base_dir/extracted" 

cd clfs* 

# copy edited Make
cp $base_dir/Makefile "$base_dir/extracted"/clfs*

make DESTDIR=${LJOS}/ install-bootscripts
ln -sv ../rc.d/startup ${LJOS}/etc/init.d/rcS

#####################################################################################

# Zlib

# Uncompress the Zlib tarball and change into its directory. Then configure, build and install the package:


cd "$base_dir/extracted" 

cd zlib* 

sed -i 's/-O3/-Os/g' configure
./configure --prefix=/usr --shared
make && make DESTDIR=${LJOS}/ install


# Now, because some packages may look for Zlib libraries in the /lib directory instead of the /lib64 directory, apply the following changes:

mv -v ${LJOS}/usr/lib/libz.so.* ${LJOS}/lib
ln -svf ../../lib/libz.so.1 ${LJOS}/usr/lib/libz.so
ln -svf ../../lib/libz.so.1 ${LJOS}/usr/lib/libz.so.1
ln -svf ../lib/libz.so.1 ${LJOS}/lib64/libz.so.1


#####################################################################################



