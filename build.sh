#!/bin/bash

set -euo pipefail

sudo rm -rf out
mkdir -p out
docker build -t kernel kernel
docker run --rm -v $(pwd)/out:/out kernel

docker build -t u-boot u-boot
docker run --rm -v $(pwd)/out:/out u-boot
mkimage -C none -A arm64 -T script -d u-boot/boot.cmd out/boot.scr
cp u-boot/boot.cmd out/boot.cmd

rm -f out/sdcard.img
dd if=/dev/zero of=out/sdcard.img bs=1M count=150
sfdisk out/sdcard.img << EOF
start=2048,size=102400,type=0c,bootable
start=104448,type=83
EOF
dd if=out/u-boot-sunxi-with-spl.bin of=out/sdcard.img bs=1024 seek=8

sudo losetup -D
LODEV="$(sudo losetup -fP out/sdcard.img --show)"
sudo mkfs.vfat ${LODEV}p1
sudo mkfs.ext4 ${LODEV}p2
sudo rm -rf /mnt/sdcard
sudo mkdir -p /mnt/sdcard
sudo mount ${LODEV}p2 /mnt/sdcard
sudo mkdir -p /mnt/sdcard/boot
sudo mount ${LODEV}p1 /mnt/sdcard/boot
sudo cp -v out/Image /mnt/sdcard/boot/
sudo cp -v out/boot.scr /mnt/sdcard/boot/
sudo cp -v out/boot.cmd /mnt/sdcard/boot/
sudo cp -v out/sun50i-h616-mangopi-mcore.dtb /mnt/sdcard/boot/
sudo mkdir -p /mnt/sdcard/lib/modules/
sudo cp -r -v out/modules/lib/modules/$(ls out/modules/lib/modules) /mnt/sdcard/lib/modules/
sudo sync
sudo umount /mnt/sdcard/boot
sudo umount /mnt/sdcard
sudo losetup -D

# if /run/media/reddragon/armbian_root exists
if [ -d "/run/media/reddragon/armbian_root" ]; then
    sudo cp -v out/Image /run/media/reddragon/armbian_root/boot/
    sudo cp -v out/boot.scr /run/media/reddragon/armbian_root/boot/
    sudo cp -v out/boot.cmd /run/media/reddragon/armbian_root/boot/
    sudo cp -v out/sun50i-h616-mangopi-mcore.dtb /run/media/reddragon/armbian_root/boot/
    MODULE_VERSION_DIR="$(ls out/modules/lib/modules)"
    sudo rm -rf "/run/media/reddragon/armbian_root/lib/modules/$MODULE_VERSION_DIR"
    sudo cp -r -v "out/modules/lib/modules/$MODULE_VERSION_DIR" /run/media/reddragon/armbian_root/lib/modules/
fi
