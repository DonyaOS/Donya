# /bin/bash
# Donya OS
place=$(pwd)

find . -print0 | cpio --null -ov --format=newc \
	| gzip -9 > ~/initramfs.cpio.gz
qemu-system-x86_64 -kernel $place/pack/linux-5.7.9/arch/x86/boot/bzImage \
	-initrd ~/initramfs.cpio.gz -nographic \
	-append "console=ttyS0"

