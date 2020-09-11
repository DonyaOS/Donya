[ -f dependencies/linux-5.8.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/linux-5.8.tar.xz" "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.8.tar.xz"; }
[ -f dependencies/gcc-10.2.0.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/gcc-10.2.0.tar.xz" "https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz"; }
[ -f dependencies/zlib-1.2.11.tar.gz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/zlib-1.2.11.tar.gz" "https://deac-ams.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz"; }
[ -f dependencies/mpfr-4.1.0.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/mpfr-4.1.0.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.xz"; }
[ -f dependencies/mpc-1.1.0.tar.gz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/mpc-1.1.0.tar.gz" "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"; }
[ -f dependencies/gmp-6.2.0.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/gmp-6.2.0.tar.xz" "https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz"; }
[ -f dependencies/clfs-embedded-bootscripts-1.0-pre5.tar.bz2 ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/clfs-embedded-bootscripts-1.0-pre5.tar.bz2" "http://ftp.osuosl.org/pub/clfs/conglomeration/clfs-embedded-bootscripts/clfs-embedded-bootscripts-1.0-pre5.tar.bz2"; }
[ -f dependencies/busybox-1.32.0.tar.bz2 ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/busybox-1.32.0.tar.bz2" "https://www.busybox.net/downloads/busybox-1.32.0.tar.bz2"; }
[ -f dependencies/binutils-2.35.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/binutils-2.35.tar.xz" "https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz"; }
[ -f dependencies/ethtool-5.8.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/ethtool-5.8.tar.xz" "https://fossies.org/linux/misc/ethtool-5.8.tar.xz"; }
[ -f dependencies/glibc-2.32.tar.xz ] && { echo "$FILE exist."; } || { echo "Downloading $FILE...";wget -O "dependencies/glibc-2.32.tar.xz" "https://fossies.org/linux/misc/glibc-2.32.tar.xz"; }

