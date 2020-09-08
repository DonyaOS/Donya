# 1.  Configuring the Environment

# turn on Bash hash functions
set +h

# Make sure that newly created files/directories are writable only by the owner (for example, the currently logged in user account)
umask 022

#  Use your home directory as the main build directory
export LJOS=~/LJOS
mkdir -pv ${LJOS}

export LC_ALL=POSIX
export PATH=${LJOS}/cross-tools/bin:/bin:/usr/bin


# Create the target image's filesystem hierarchy
# This directory tree is based on the Filesystem Hierarchy Standard (FHS), which is defined and hosted by the Linux Foundation


mkdir -pv ${LJOS}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -pv ${LJOS}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv ${LJOS}/var/{lock,log,mail,run,spool}
mkdir -pv ${LJOS}/var/{opt,cache,lib/{misc,locate},local}

install -dv -m 0750 ${LJOS}/root
install -dv -m 1777 ${LJOS}{/var,}/tmp
install -dv ${LJOS}/etc/init.d

mkdir -pv ${LJOS}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv ${LJOS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${LJOS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${LJOS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}

for dir in ${LJOS}/usr{,/local}; do
    ln -sv share/{man,doc,info} ${dir}
done


# Create the directory for a cross-compilation toolchain
install -dv ${LJOS}/cross-tools{,/bin}

# Use a symlink to /proc/mounts to maintain a list of mounted filesystems properly in the /etc/mtab file
ln -svf ../proc/mounts ${LJOS}/etc/mtab

# Then create the /etc/passwd file, listing the root user account (note: for now, you won't be setting the account password; you'll do that after booting up into the target image for the first time)
cat > ${LJOS}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

# Create the /etc/group file with the following command: 
cat > ${LJOS}/etc/group << "EOF"
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
cat > ${LJOS}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order

rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
devpts          /dev/pts        devpts  gid=4,mode=620  0      0
tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF

# The target system's /etc/profile to be used by the Almquist shell (ash) once the user is logged in to the target machine
cat > ${LJOS}/etc/profile << "EOF"
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
echo "LJOS-test" > ${LJOS}/etc/HOSTNAME


# And, /etc/issue, which will be displayed prominently at the login prompt: 
cat > ${LJOS}/etc/issue<< "EOF"
Linux Journal OS 0.1a
Kernel \r on an \m

EOF


# You won't use systemd here (this wasn't a political decision; it's due to convenience and for simplicity's sake). Instead, you'll use the basic init process provided by BusyBox. This requires that you define an /etc/inittab file: 

cat > ${LJOS}/etc/inittab<< "EOF"
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

cat > ${LJOS}/etc/mdev.conf<< "EOF"
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
mkdir ${LJOS}/boot/grub/
###$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


cat > ${LJOS}/boot/grub/grub.cfg<< "EOF"

set default=0
set timeout=5

set root=(hd0,1)

menuentry "Linux Journal OS 0.1a" {
        linux   /boot/vmlinuz-5.8.0 root=/dev/sda1 ro quiet
}
EOF


# Finally, initialize the log files and give them proper permissions: 

touch ${LJOS}/var/run/utmp ${LJOS}/var/log/{btmp,lastlog,wtmp}
chmod -v 664 ${LJOS}/var/run/utmp ${LJOS}/var/log/lastlog