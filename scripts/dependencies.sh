[[ -d packages ]] || mkdir packages

echo "linux";
[ -f packages/linux-5.8.tar.xz ] && { echo "linux-5.8.tar.xz exist."; } || { echo "Downloading linux-5.8.tar.xz...";wget -O "packages/linux-5.8.tar.xz" "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.8.tar.xz"; }

echo "gcc";
[ -f packages/gcc-10.2.0.tar.xz ] && { echo "gcc-10.2.0.tar.xz exist."; } || { echo "Downloading gcc-10.2.0.tar.xz...";wget -O "packages/gcc-10.2.0.tar.xz" "https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz"; }

echo "zlib";
[ -f packages/zlib-1.2.11.tar.gz ] && { echo "zlib-1.2.11.tar.gz exist."; } || { echo "Downloading zlib-1.2.11.tar.gz...";wget -O "packages/zlib-1.2.11.tar.gz" "https://deac-ams.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz"; }

echo "mpfr";
[ -f packages/mpfr-4.1.0.tar.xz ] && { echo "mpfr-4.1.0.tar.xz exist."; } || { echo "Downloading mpfr-4.1.0.tar.xz...";wget -O "packages/mpfr-4.1.0.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.xz"; }

echo "mpc";
[ -f packages/mpc-1.1.0.tar.gz ] && { echo "mpc-1.1.0.tar.gz exist."; } || { echo "Downloading mpc-1.1.0.tar.gz...";wget -O "packages/mpc-1.1.0.tar.gz" "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"; }

echo "gmp";
[ -f packages/gmp-6.2.0.tar.xz ] && { echo "gmp-6.2.0.tar.xz exist."; } || { echo "Downloading gmp-6.2.0.tar.xz...";wget -O "packages/gmp-6.2.0.tar.xz" "https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz"; }

echo "clfs-embedded-bootscripts";
[ -f packages/clfs-embedded-bootscripts-1.0-pre5.tar.bz2 ] && { echo "clfs-embedded-bootscripts-1.0-pre5.tar.bz2 exist."; } || { echo "Downloading clfs-embedded-bootscripts-1.0-pre5.tar.bz2...";wget -O "packages/clfs-embedded-bootscripts-1.0-pre5.tar.bz2" "http://ftp.osuosl.org/pub/clfs/conglomeration/clfs-embedded-bootscripts/clfs-embedded-bootscripts-1.0-pre5.tar.bz2"; }

echo "busybox";
[ -f packages/busybox-1.32.0.tar.bz2 ] && { echo "busybox-1.32.0.tar.bz2 exist."; } || { echo "Downloading busybox-1.32.0.tar.bz2...";wget -O "packages/busybox-1.32.0.tar.bz2" "https://www.busybox.net/downloads/busybox-1.32.0.tar.bz2"; }

echo "binutils";
[ -f packages/binutils-2.35.tar.xz ] && { echo "binutils-2.35.tar.xz exist."; } || { echo "Downloading binutils-2.35.tar.xz...";wget -O "packages/binutils-2.35.tar.xz" "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz"; }

echo "ethtool";
[ -f packages/ethtool-5.8.tar.xz ] && { echo "ethtool-5.8.tar.xz exist."; } || { echo "Downloading ethtool-5.8.tar.xz...";wget -O "packages/ethtool-5.8.tar.xz" "https://fossies.org/linux/misc/ethtool-5.8.tar.xz"; }

echo "glibc";
[ -f packages/glibc-2.32.tar.xz ] && { echo "glibc-2.32.tar.xz exist."; } || { echo "Downloading glibc-2.32.tar.xz...";wget -O "packages/glibc-2.32.tar.xz" "https://fossies.org/linux/misc/glibc-2.32.tar.xz"; }
