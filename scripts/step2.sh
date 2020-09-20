


# 2. Build the Cross Compiler


#################################
#Extract#########################
#################################

base_dir=$(pwd)

## Create directories
mkdir -p "$base_dir"/{packages,extracted}

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

export donyaOS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export donyaOS_TARGET=x86_64-unknown-linux-gnu
export donyaOS_CPU=k8
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
make ARCH=${donyaOS_ARCH} headers_check
make ARCH=${donyaOS_ARCH} INSTALL_HDR_PATH=dest headers_install

cp -rv dest/include/* ${donyaOS}/usr/include
############################################



# Binutils

# Binutils contains a linker, assembler and other tools needed to handle compiled object files. Uncompress the tarball. Then create the binutils-build directory and change into it: 

cd "$base_dir/extracted" || exit 1

# cd binutils* || exit 1

mkdir binutils-build
cd binutils-build/

../binutils-2.35/configure --prefix=${donyaOS}/cross-tools \
--target=${donyaOS_TARGET} --with-sysroot=${donyaOS} \
--disable-nls --enable-shared --disable-multilib

make configure-host && make

ln -sv lib ${donyaOS}/cross-tools/lib64

make install

# Copy over the following header file to the target's filesystem:
cp -v ../binutils-2.35/include/libiberty.h ${donyaOS}/usr/include

#GCC (Static)

# Before building the final cross-compiler toolchain, you first must build a statically compiled toolchain to build the C library (glibc) to which the final GCC cross compiler will link.

# Uncompress the GCC tarball, and then uncompress the following packages and move them into the GCC root directory: 

cd "$base_dir/extracted" || exit 1

mv gmp* gcc-10.2.0/gmp
mv mpfr* gcc-10.2.0/mpfr
mv mpc* gcc-10.2.0/mpc

mkdir gcc-static
cd gcc-static/

AR=ar LDFLAGS="-Wl,-rpath,${donyaOS}/cross-tools/lib" \
../gcc-10.2.0/configure --prefix=${donyaOS}/cross-tools \
--build=${donyaOS_HOST} --host=${donyaOS_HOST} \
--target=${donyaOS_TARGET} \
--with-sysroot=${donyaOS}/target --disable-nls \
--disable-shared \
--with-mpfr-include=$(pwd)/../gcc-10.2.0/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--without-headers --with-newlib --disable-decimal-float \
--disable-libgomp --disable-libmudflap --disable-libssp \
--disable-threads --enable-languages=c,c++ \
--disable-multilib --with-arch=${donyaOS_CPU}


make all-gcc all-target-libgcc && \
make install-gcc install-target-libgcc

ln -vs libgcc.a `${donyaOS_TARGET}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

# Glibc

# Uncompress the glibc tarball. Then create the glibc-build directory and change into it: 

cd "$base_dir/extracted" || exit 1

mkdir glibc-build
cd glibc-build/

# Configure the following build flags:

echo "libc_cv_forced_unwind=yes" > config.cache
echo "libc_cv_c_cleanup=yes" >> config.cache
echo "libc_cv_ssp=no" >> config.cache
echo "libc_cv_ssp_strong=no" >> config.cache


BUILD_CC="gcc" CC="${donyaOS_TARGET}-gcc" \
AR="${donyaOS_TARGET}-ar" \
RANLIB="${donyaOS_TARGET}-ranlib" CFLAGS="-O2" \
../glibc-2.32/configure --prefix=/usr \
--host=${donyaOS_TARGET} --build=${donyaOS_HOST} \
--disable-profile --enable-add-ons --with-tls \
--enable-kernel=2.6.32 --with-__thread \
--with-binutils=${donyaOS}/cross-tools/bin \
--with-headers=${donyaOS}/usr/include \
--cache-file=config.cache

make && make install_root=${donyaOS}/ install


# This part problematic but work if copy paste commands

# GCC (Final)

# As I mentioned previously, you'll now build the final GCC cross compiler that will link to the C library built and installed in the previous step. Create the gcc-build directory and change into it: 

cd "$base_dir/extracted" || exit 1

mkdir gcc-build
cd gcc-build/

AR=ar LDFLAGS="-Wl,-rpath,${donyaOS}/cross-tools/lib" \
../gcc-10.2.0/configure --prefix=${donyaOS}/cross-tools \
--build=${donyaOS_HOST} --target=${donyaOS_TARGET} \
--host=${donyaOS_HOST} --with-sysroot=${donyaOS} \
--disable-nls --enable-shared \
--enable-languages=c,c++ --enable-c99 \
--enable-long-long \
--with-mpfr-include=$(pwd)/../gcc-10.2.0/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--disable-multilib --with-arch=${donyaOS_CPU}

make && make install

cp -v ${donyaOS}/cross-tools/${donyaOS_TARGET}/lib64/libgcc_s.so.1 ${donyaOS}/lib64


###################################################################################################


