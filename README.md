# BliKVM V4 from Scratch

## Introduction

This project is an experiment to build the complete software stack from U-Boot to KVMD on the Allwinner BliKVM V4 box. The goal is to minimize the OS size and security attack surface, and to provide a constantly up-to-date environment.

## TODOs

- Make initramfs with bt/wifi firmware
- Test wifi (`sudo armbian-config`)
- Fix u-boot
- Test USB gadget
- Test GPIOs
  - fan (`GPIOI13(269)`)
  - buzzer (`GPIOI15(271)`)
  - ATX control
- Minify kernel
- Pack KVMD into initramfs and boot using an overlayfs rootfs
