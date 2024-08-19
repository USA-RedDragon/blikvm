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
