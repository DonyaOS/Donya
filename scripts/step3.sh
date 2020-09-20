
#3. Building the Target Image

# The hard part is now complete—you have the cross compiler. Now, let's focus on building the components that will be installed on the target image. This includes various libraries and utilities and, of course, the Linux kernel itself. 


# BusyBox

# Uncompress the tarball and change into its directory. Then load the default compilation configuration template: 


cd "$base_dir/extracted" || exit 1

cd busybox*

make CROSS_COMPILE="${donyaOS_TARGET}-" defconfig

make CROSS_COMPILE="${donyaOS_TARGET}-"
make CROSS_COMPILE="${donyaOS_TARGET}-" CONFIG_PREFIX="${donyaOS}" install


# Install the following Perl script, as you'll need it for the kernel build below:

cp -v examples/depmod.pl ${donyaOS}/cross-tools/bin
chmod 755 ${donyaOS}/cross-tools/bin/depmod.pl


## The Linux Kernel

# Change into the kernel package directory and run the following to set the default x86-64 configuration template: 

cd "$base_dir/extracted" || exit 1

cd linux*


make ARCH=${donyaOS_ARCH} \
CROSS_COMPILE=${donyaOS_TARGET}- x86_64_defconfig


make ARCH=${donyaOS_ARCH} CROSS_COMPILE=${donyaOS_TARGET}-

make ARCH=${donyaOS_ARCH} CROSS_COMPILE=${donyaOS_TARGET}- \
INSTALL_MOD_PATH=${donyaOS} modules_install


# You'll need to copy a few files into the /boot directory for GRUB:

cp -v arch/x86/boot/bzImage ${donyaOS}/boot/vmlinuz-5.8.0
cp -v System.map ${donyaOS}/boot/System.map-5.8.0
cp -v .config ${donyaOS}/boot/config-5.8.0


# Then run the previously installed Perl script provided by the BusyBox package:

${donyaOS}/cross-tools/bin/depmod.pl \
-F ${donyaOS}/boot/System.map-5.8.0 \
-b ${donyaOS}/lib/modules/5.8.0

#####################################################################################

# The Bootscripts 

cd "$base_dir/extracted" 

cd clfs* 

# copy edited Make
cp $base_dir/Makefile "$base_dir/extracted"/clfs*

make DESTDIR=${donyaOS}/ install-bootscripts
ln -sv ../rc.d/startup ${donyaOS}/etc/init.d/rcS

#####################################################################################

# Zlib

# Uncompress the Zlib tarball and change into its directory. Then configure, build and install the package:


cd "$base_dir/extracted" 

cd zlib* 

sed -i 's/-O3/-Os/g' configure
./configure --prefix=/usr --shared
make && make DESTDIR=${donyaOS}/ install


# Now, because some packages may look for Zlib libraries in the /lib directory instead of the /lib64 directory, apply the following changes:

mv -v ${donyaOS}/usr/lib/libz.so.* ${donyaOS}/lib
ln -svf ../../lib/libz.so.1 ${donyaOS}/usr/lib/libz.so
ln -svf ../../lib/libz.so.1 ${donyaOS}/usr/lib/libz.so.1
ln -svf ../lib/libz.so.1 ${donyaOS}/lib64/libz.so.1


#####################################################################################



