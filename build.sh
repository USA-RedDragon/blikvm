#!/bin/bash

set -euo pipefail

sudo rm -rf out
mkdir -p out
docker build -t kernel -f Dockerfile.kernel .
docker run --rm -v $(pwd)/out:/out kernel
mkimage -C none -A arm -T script -d boot.cmd out/boot.scr
cp boot.cmd out/boot.cmd
