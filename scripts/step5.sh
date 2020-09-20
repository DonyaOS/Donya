

# 5. Create patition and boot

# cat /proc/partitions


# lsblk

# use `/dev/sdb` to boot OS


# Create a partiotion on it

# sudo fdisk -l /dev/sdb , fdisk or parted

# Format

sudo umount /dev/sdb1
sudo mkfs.ext4 /dev/sdb1

sudo mkdir "$base_dir"/donya/

sudo mount /dev/sdb1 "$base_dir"/donya/
sudo tar xJf ${base_dir}/donyaOS-build.tar.xz -C "$base_dir"/donya/

sudo grub-install --root-directory="$base_dir"/donya/ /dev/sdb

# # Booting Up the OS

sudo qemu-system-x86_64 /dev/sdb


# username: root

