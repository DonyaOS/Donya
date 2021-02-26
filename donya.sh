# shellcheck disable=SC2148
# 1.  Configuring the Environment

# turn on Bash hash functions
set +h

# Make sure that newly created files/directories are writable only by the owner (for example, the currently logged in user account)
umask 022

#  Use your home directory as the main build directory
# shellcheck disable=SC2155
export donyaOS=$(pwd)/donyaOS
mkdir -pv "${donyaOS}"

export LC_ALL=POSIX
export PATH=${donyaOS}/cross-tools/bin:/bin:/usr/bin


# Create the target image's filesystem hierarchy
# This directory tree is based on the Filesystem Hierarchy Standard (FHS), which is defined and hosted by the Linux Foundation


mkdir -pv "${donyaOS}"/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -pv "${donyaOS}"/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv "${donyaOS}"/var/{lock,log,mail,run,spool}
mkdir -pv "${donyaOS}"/var/{opt,cache,lib/{misc,locate},local}

install -dv -m 0750 "${donyaOS}"/root
install -dv -m 1777 "${donyaOS}"{/var,}/tmp
install -dv "${donyaOS}"/etc/init.d

mkdir -pv "${donyaOS}"/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv "${donyaOS}"/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv "${donyaOS}"/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv "${donyaOS}"/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}

for dir in ${donyaOS}/usr{,/local}; do
    ln -sv share/{man,doc,info} "${dir}"
done


# Create the directory for a cross-compilation toolchain
install -dv "${donyaOS}"/cross-tools{,/bin}

# Use a symlink to /proc/mounts to maintain a list of mounted filesystems properly in the /etc/mtab file
ln -svf /proc/mounts "${donyaOS}"/etc/mtab

# Then create the /etc/passwd file, listing the root user account (note: for now, you won't be setting the account password; you'll do that after booting up into the target image for the first time)
cat > "${donyaOS}"/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

# Create the /etc/group file with the following command:
cat > "${donyaOS}"/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
video:x:12:
utmp:x:13:
usb:x:14:
EOF

# The target system's /etc/fstab
cat > "${donyaOS}"/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order
rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
devpts          /dev/pts        devpts  gid=4,mode=620  0      0
tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF

# The target system's /etc/profile to be used by the Almquist shell (ash) once the user is logged in to the target machine
cat > "${donyaOS}"/etc/profile << "EOF"
export PATH=/bin:/usr/bin
if [ `id -u` -eq 0 ] ; then
    PATH=/bin:/sbin:/usr/bin:/usr/sbin
    unset HISTFILE
fi
# Set up some environment variables.
export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
EOF

# The target machine's hostname (you can change this any time):
echo "donyaOS-machine" > "${donyaOS}"/etc/HOSTNAME


# And, /etc/issue, which will be displayed prominently at the login prompt:
cat > "${donyaOS}"/etc/issue<< "EOF"
donyaOS 0.001a
Kernel \r on an \m
EOF


# You won't use systemd here (this wasn't a political decision; it's due to convenience and for simplicity's sake). Instead, you'll use the basic init process provided by BusyBox. This requires that you define an /etc/inittab file:

cat > "${donyaOS}"/etc/inittab<< "EOF"
::sysinit:/etc/rc.d/startup
tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6
::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
EOF

# Also as a result of leveraging BusyBox to simplify some of the most common Linux system functionality # you'll use mdev instead of udev, which requires you to define the following /etc/mdev.conf file:

cat > "${donyaOS}"/etc/mdev.conf<< "EOF"
# Devices:
# Syntax: %s %d:%d %s
# devices user:group mode
# null does already exist; therefore ownership has to
# be changed with command
null    root:root 0666  @chmod 666 $MDEV
zero    root:root 0666
grsec   root:root 0660
full    root:root 0666
random  root:root 0666
urandom root:root 0444
hwrandom root:root 0660
# console does already exist; therefore ownership has to
# be changed with command
console root:tty 0600 @mkdir -pm 755 fd && cd fd && for x in 0 1 2 3 ; do ln -sf /proc/self/fd/$x $x; done
kmem    root:root 0640
mem     root:root 0640
port    root:root 0640
ptmx    root:tty 0666
# ram.*
ram([0-9]*)     root:disk 0660 >rd/%1
loop([0-9]+)    root:disk 0660 >loop/%1
sd[a-z].*       root:disk 0660 */lib/mdev/usbdisk_link
hd[a-z][0-9]*   root:disk 0660 */lib/mdev/ide_links
tty             root:tty 0666
tty[0-9]        root:root 0600
tty[0-9][0-9]   root:tty 0660
ttyO[0-9]*      root:tty 0660
pty.*           root:tty 0660
vcs[0-9]*       root:tty 0660
vcsa[0-9]*      root:tty 0660
ttyLTM[0-9]     root:dialout 0660 @ln -sf $MDEV modem
ttySHSF[0-9]    root:dialout 0660 @ln -sf $MDEV modem
slamr           root:dialout 0660 @ln -sf $MDEV slamr0
slusb           root:dialout 0660 @ln -sf $MDEV slusb0
fuse            root:root  0666
# misc stuff
agpgart         root:root 0660  >misc/
psaux           root:root 0660  >misc/
rtc             root:root 0664  >misc/
# input stuff
event[0-9]+     root:root 0640 =input/
ts[0-9]         root:root 0600 =input/
# v4l stuff
vbi[0-9]        root:video 0660 >v4l/
video[0-9]      root:video 0660 >v4l/
# load drivers for usb devices
usbdev[0-9].[0-9]       root:root 0660 */lib/mdev/usbdev
usbdev[0-9].[0-9]_.*    root:root 0660
EOF


# You'll need to create a /boot/grub/grub.cfg for the GRUB bootloader that will be installed on the target machine's physical or virtual HDD (note: the kernel image defined in this file needs to reflect the image built and installed on the target machine):

### This is what I add
mkdir "${donyaOS}"/boot/grub/
###$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


cat > "${donyaOS}"/boot/grub/grub.cfg<< "EOF"
set default=0
set timeout=5
insmod part_msdos
insmod ext2

set root='hd0,msdos1'

menuentry "donyaOS 0.001a" {
        linux   /boot/vmlinuz-5.8.0 root=/dev/sdb1 ro quiet
}

EOF


# Finally, initialize the log files and give them proper permissions:

touch "${donyaOS}"/var/run/utmp "${donyaOS}"/var/log/{btmp,lastlog,wtmp}
chmod -v 664 "${donyaOS}"/var/run/utmp "${donyaOS}"/var/log/lastlog


# 2. Build the Cross Compiler


#################################
#Extract#########################
#################################

base_dir=$(pwd)

## Create directories
mkdir -p "$base_dir"/{packages,extracted}


## download dependencies

wget -nc -i packages-list.txt -P packages/


# busybox
tar -xvf "$base_dir/packages/busybox-1.32.0.tar.bz2" -C "$base_dir/extracted"

# linux
tar -xvf "$base_dir/packages/linux-5.8.tar.xz" -C "$base_dir/extracted"

# init
tar -xvf "$base_dir/packages/clfs-embedded-bootscripts-1.0-pre5.tar.bz2" -C "$base_dir/extracted"

# binutils
tar -xvf "$base_dir/packages/binutils-2.35.tar.xz" -C "$base_dir/extracted"

# gcc
tar -xvf "$base_dir/packages/gcc-10.2.0.tar.xz" -C "$base_dir/extracted"

# gmp
tar -xvf "$base_dir/packages/gmp-6.2.0.tar.xz" -C "$base_dir/extracted"

# mpfr
tar -xvf "$base_dir/packages/mpfr-4.1.0.tar.xz" -C "$base_dir/extracted"

# mpc
tar -xvf "$base_dir/packages/mpc-1.1.0.tar.gz" -C "$base_dir/extracted"

# glibc
tar -xvf "$base_dir/packages/glibc-2.32.tar.xz" -C "$base_dir/extracted"

# zlib
tar -xvf "$base_dir/packages/zlib-1.2.11.tar.gz" -C "$base_dir/extracted"


###########################################################################

unset CFLAGS
unset CXXFLAGS

# define the most vital parts of the host/target variables needed to create the cross-compiler toolchain and target image:

# shellcheck disable=SC2155,SC2001
export donyaOS_HOST=$(echo "${MACHTYPE}" | sed "s/-[^-]*/-cross/")
export donyaOS_TARGET=x86_64-unknown-linux-gnu
export donyaOS_CPU=k8
# shellcheck disable=SC2155
export donyaOS_ARCH=$(echo ${donyaOS_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/')
export donyaOS_ENDIAN=little

###########################################################################



# # Kernel Headers

# # The kernel's standard header files need to be installed for the cross compiler. Uncompress the kernel tarball and change into its directory. Then run:

echo "########Compile linux##########"

cd "$base_dir/extracted" || exit 1

cd linux* || exit 1


## speed Up make
NB_CORES=$(grep -c '^processor' /proc/cpuinfo)
export MAKEFLAGS="-j$((NB_CORES+1)) -l${NB_CORES}"

###Headers
# make clean

make mrproper
make ARCH="${donyaOS_ARCH}" headers_check
make ARCH="${donyaOS_ARCH}" INSTALL_HDR_PATH=dest headers_install

cp -rv dest/include/* "${donyaOS}"/usr/include
############################################



# Binutils

# Binutils contains a linker, assembler and other tools needed to handle compiled object files. Uncompress the tarball. Then create the binutils-build directory and change into it:

cd "$base_dir/extracted" || exit 1

# cd binutils* || exit 1

mkdir binutils-build
cd binutils-build/ || exit

../binutils-2.35/configure --prefix="${donyaOS}"/cross-tools \
--target=${donyaOS_TARGET} --with-sysroot="${donyaOS}" \
--disable-nls --enable-shared --disable-multilib

make configure-host && make

ln -sv lib "${donyaOS}"/cross-tools/lib64

make install


# Copy over the following header file to the target's filesystem:
cp -v ../binutils-2.35/include/libiberty.h "${donyaOS}"/usr/include


#GCC (Static)

# Before building the final cross-compiler toolchain, you first must build a statically compiled toolchain to build the C library (glibc) to which the final GCC cross compiler will link.

# Uncompress the GCC tarball, and then uncompress the following packages and move them into the GCC root directory:

cd "$base_dir/extracted" || exit 1


cp -r gmp* gcc-10.2.0/gmp
cp -r mpfr* gcc-10.2.0/mpfr
cp -r mpc* gcc-10.2.0/mpc


mkdir gcc-static
cd gcc-static/ || exit

AR=ar LDFLAGS="-Wl,-rpath,${donyaOS}/cross-tools/lib" \
../gcc-10.2.0/configure --prefix="${donyaOS}"/cross-tools \
--build="${donyaOS_HOST}" --host="${donyaOS_HOST}" \
--target=${donyaOS_TARGET} \
--with-sysroot="${donyaOS}"/target --disable-nls \
--disable-shared \
--with-mpfr-include=../gcc-10.2.0/mpfr/src \
--with-mpfr-lib=../gcc-10.2.0/mpfr/src/.libs \
--without-headers --with-newlib --disable-decimal-float \
--disable-libgomp --disable-libmudflap --disable-libssp \
--disable-threads --enable-languages=c,c++ \
--disable-multilib --with-arch=${donyaOS_CPU}


make all-gcc all-target-libgcc && \
make install-gcc install-target-libgcc

ln -vs libgcc.a "$(${donyaOS_TARGET}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/')"

# Glibc

# Uncompress the glibc tarball. Then create the glibc-build directory and change into it:

cd "$base_dir/extracted" || exit 1


mkdir glibc-build
cd glibc-build/ || exit

# Configure the following build flags:

echo "libc_cv_forced_unwind=yes" > config.cache
# shellcheck disable=SC2129
echo "libc_cv_c_cleanup=yes" >> config.cache
echo "libc_cv_ssp=no" >> config.cache
echo "libc_cv_ssp_strong=no" >> config.cache



BUILD_CC="gcc" CC="${donyaOS_TARGET}-gcc" \
AR="${donyaOS_TARGET}-ar" \
RANLIB="${donyaOS_TARGET}-ranlib" CFLAGS="-O2" \
../glibc-2.32/configure --prefix=/usr \
--host=${donyaOS_TARGET} --build="${donyaOS_HOST}" \
--disable-profile --enable-add-ons --with-tls \
--enable-kernel=2.6.32 --with-__thread \
--with-binutils="${donyaOS}"/cross-tools/bin \
--with-headers="${donyaOS}"/usr/include \
--cache-file=config.cache

make && make install_root="${donyaOS}"/ install


# This part problematic but work if copy paste commands

# GCC (Final)

# As I mentioned previously, you'll now build the final GCC cross compiler that will link to the C library built and installed in the previous step. Create the gcc-build directory and change into it:

cd "$base_dir/extracted" || exit 1

mkdir gcc-build
cd gcc-build/ || exit

AR=ar LDFLAGS="-Wl,-rpath,${donyaOS}/cross-tools/lib" \
../gcc-10.2.0/configure --prefix="${donyaOS}"/cross-tools \
--build="${donyaOS_HOST}" --target=${donyaOS_TARGET} \
--host="${donyaOS_HOST}" --with-sysroot="${donyaOS}" \
--disable-nls --enable-shared \
--enable-languages=c,c++ --enable-c99 \
--enable-long-long \
--with-mpfr-include="$(pwd)"/../gcc-10.2.0/mpfr/src \
--with-mpfr-lib="$(pwd)"/mpfr/src/.libs \
--disable-multilib --with-arch=${donyaOS_CPU}

make && make install

cp -v "${donyaOS}"/cross-tools/${donyaOS_TARGET}/lib64/libgcc_s.so.1 "${donyaOS}"/lib64


###################################################################################################

#3. Building the Target Image

# The hard part is now complete—you have the cross compiler. Now, let's focus on building the components that will be installed on the target image. This includes various libraries and utilities and, of course, the Linux kernel itself.


# BusyBox

# Uncompress the tarball and change into its directory. Then load the default compilation configuration template:


cd "$base_dir/extracted" || exit 1

cd busybox* || exit

make CROSS_COMPILE="${donyaOS_TARGET}-" defconfig

make CROSS_COMPILE="${donyaOS_TARGET}-"
make CROSS_COMPILE="${donyaOS_TARGET}-" CONFIG_PREFIX="${donyaOS}" install


# Install the following Perl script, as you'll need it for the kernel build below:

cp -v examples/depmod.pl "${donyaOS}"/cross-tools/bin
chmod 755 "${donyaOS}"/cross-tools/bin/depmod.pl


## The Linux Kernel

# Change into the kernel package directory and run the following to set the default x86-64 configuration template:

cd "$base_dir/extracted" || exit 1

cd linux* || exit


make ARCH="${donyaOS_ARCH}" \
CROSS_COMPILE=${donyaOS_TARGET}- x86_64_defconfig


make ARCH="${donyaOS_ARCH}" CROSS_COMPILE=${donyaOS_TARGET}-

make ARCH="${donyaOS_ARCH}" CROSS_COMPILE=${donyaOS_TARGET}- \
INSTALL_MOD_PATH="${donyaOS}" modules_install


# You'll need to copy a few files into the /boot directory for GRUB:

cp -v arch/x86/boot/bzImage "${donyaOS}"/boot/vmlinuz-5.8.0
cp -v System.map "${donyaOS}"/boot/System.map-5.8.0
cp -v .config "${donyaOS}"/boot/config-5.8.0


# Then run the previously installed Perl script provided by the BusyBox package:

"${donyaOS}"/cross-tools/bin/depmod.pl \
-F "${donyaOS}"/boot/System.map-5.8.0 \
-b "${donyaOS}"/lib/modules/5.8.0

#####################################################################################


# The Bootscripts

cd "$base_dir/extracted" || exit

cd clfs* || exit

# copy edited Make
cp "$base_dir"/Makefile "$base_dir/extracted"/clfs*

make DESTDIR="${donyaOS}"/ install-bootscripts
ln -sv ../rc.d/startup "${donyaOS}"/etc/init.d/rcS

#####################################################################################

# Zlib

# Uncompress the Zlib tarball and change into its directory. Then configure, build and install the package:


cd "$base_dir/extracted" || exit

cd zlib* || exit

sed -i 's/-O3/-Os/g' configure
./configure --prefix=/usr --shared
make && make DESTDIR="${donyaOS}"/ install


# Now, because some packages may look for Zlib libraries in the /lib directory instead of the /lib64 directory, apply the following changes:

mv -v "${donyaOS}"/usr/lib/libz.so.* "${donyaOS}"/lib
ln -svf ../../lib/libz.so.1 "${donyaOS}"/usr/lib/libz.so
ln -svf ../../lib/libz.so.1 "${donyaOS}"/usr/lib/libz.so.1
ln -svf ../lib/libz.so.1 "${donyaOS}"/lib64/libz.so.1


#####################################################################################


# 4. Installing the Target Image

# All of the cross compilation is complete. Now you have everything you need to install the entire cross-compiled operating system to either a physical or virtual drive, but before doing that, let's not tamper with the original target build directory by making a copy of it:

mkdir -pv "${donyaOS}"-copy
cp -rf "${donyaOS}"/* "${donyaOS}"-copy

rm -rfv "${donyaOS}"-copy/cross-tools
rm -rfv "${donyaOS}"-copy/usr/src/*

# Followed by the now unneeded statically compiled library files (if any):

FILES="$(ls "${donyaOS}"-copy/usr/lib64/*.a)"
for file in $FILES; do
rm -f "$file"
done


# Now strip all debug symbols from the installed binaries. This will reduce overall file sizes and keep the target image's overall footprint to a minimum:


find "${donyaOS}"-copy/{,usr/}{bin,lib,sbin} -type f -exec sudo strip --strip-debug '{}' ';'

find "${donyaOS}"-copy/{,usr/}lib64 -type f -exec sudo strip --strip-debug '{}' ';'


# Finally, change file ownerships and create the following nodes:

sudo chown -R root:root "${donyaOS}"-copy
sudo chgrp 13 "${donyaOS}"-copy/var/run/utmp "${donyaOS}"-copy/var/log/lastlog
sudo mknod -m 0666 "${donyaOS}"-copy/dev/null c 1 3
sudo mknod -m 0600 "${donyaOS}"-copy/dev/console c 5 1
sudo chmod 4755 "${donyaOS}"-copy/bin/busybox


# Change into the target copy directory to create a tarball of the entire operating system image:

cd "${donyaOS}"-copy/ || exit

sudo tar cfJ ../donyaOS-build.tar.xz ./*

#########################################################################################################

# Finish creating donyaOS 

#########################################################################################################



# # Notice how the target image is less than 60MB. You built that—a minimal Linux operating system that occupies less than 60MB of disk space:

# sudo du -h|tail -n1


# And, that same operating system compresses to less than 20MB:

# ls -lh ../donyaOS-build*
#####################



# separate last steps




# 5. Create partition and boot

# cat /proc/partitions


# lsblk

# use `/dev/sdb` to boot OS


# Create a partition on it

# sudo fdisk -l /dev/sdb , fdisk or parted

# Format

# sudo umount /dev/sdb1
# sudo mkfs.ext4 /dev/sdb1

# sudo mkdir "$base_dir"/donya_release/

# sudo mount /dev/sdb1 "$base_dir"/donya/
# sudo tar xJf ${base_dir}/donyaOS-build.tar.xz -C "$base_dir"/donya/

# sudo grub-install --root-directory="$base_dir"/donya/ /dev/sdb

# # # Booting Up the OS

# sudo qemu-system-x86_64 /dev/sdb

# username: root
