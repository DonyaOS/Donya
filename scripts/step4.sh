

# 4. Installing the Target Image

# All of the cross compilation is complete. Now you have everything you need to install the entire cross-compiled operating system to either a physical or virtual drive, but before doing that, let's not tamper with the original target build directory by making a copy of it: 

mkdir -pv ${donyaOS}-copy
cp -rf ${donyaOS}/* ${donyaOS}-copy

rm -rfv ${donyaOS}-copy/cross-tools
rm -rfv ${donyaOS}-copy/usr/src/*

# Followed by the now unneeded statically compiled library files (if any): 

FILES="$(ls ${donyaOS}-copy/usr/lib64/*.a)"
for file in $FILES; do
rm -f $file
done


# Now strip all debug symbols from the installed binaries. This will reduce overall file sizes and keep the target image's overall footprint to a minimum:


find ${donyaOS}-copy/{,usr/}{bin,lib,sbin} -type f -exec sudo strip --strip-debug '{}' ';'

find ${donyaOS}-copy/{,usr/}lib64 -type f -exec sudo strip --strip-debug '{}' ';'


# Finally, change file ownerships and create the following nodes: 

sudo chown -R root:root ${donyaOS}-copy
sudo chgrp 13 ${donyaOS}-copy/var/run/utmp ${donyaOS}-copy/var/log/lastlog
sudo mknod -m 0666 ${donyaOS}-copy/dev/null c 1 3
sudo mknod -m 0600 ${donyaOS}-copy/dev/console c 5 1
sudo chmod 4755 ${donyaOS}-copy/bin/busybox


# Change into the target copy directory to create a tarball of the entire operating system image:

cd ${donyaOS}-copy/

sudo tar cfJ ../donyaOS-build.tar.xz *


# # Notice how the target image is less than 60MB. You built that—a minimal Linux operating system that occupies less than 60MB of disk space:

# sudo du -h|tail -n1


# And, that same operating system compresses to less than 20MB:

# ls -lh ../donyaOS-build*
#####################




