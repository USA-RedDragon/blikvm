FROM alpine AS src-trusted-firmware-a

RUN apk add --no-cache \
    git

WORKDIR /usr/src

# renovate: datasource=git-tags depName=https://review.trustedfirmware.org/TF-A/trusted-firmware-a
ARG ARM_TRUSTED_FIRMWARE_VERSION=v2.11.0

RUN git clone --branch ${ARM_TRUSTED_FIRMWARE_VERSION} --depth 1 --single-branch https://review.trustedfirmware.org/TF-A/trusted-firmware-a

FROM alpine AS src-uboot

RUN apk add --no-cache \
    git

WORKDIR /usr/src

# renovate: datasource=github-tags extractVersion=^v(?<version>.*)$ versioning=regex depName=u-boot/u-boot
ARG UBOOT_VERSION=2024.04

RUN git clone --branch v${UBOOT_VERSION} --depth 1 --single-branch https://github.com/u-boot/u-boot.git

FROM alpine AS build-trusted-firmware-a

RUN apk add --no-cache \
    llvm \
    clang \
    make \
    lld

COPY --from=src-trusted-firmware-a /usr/src/trusted-firmware-a /usr/src/trusted-firmware-a

WORKDIR /usr/src/trusted-firmware-a

ENV CC=clang
ENV AR=llvm-ar
ENV LD=ld.lld
ENV STRIP=llvm-strip
ENV OBJCOPY=llvm-objcopy
ENV OBJDUMP=llvm-objdump
ENV READELF=llvm-readelf

RUN make -j$(nproc) PLAT=sun50i_h616 bl31

RUN mkdir -p /out && cp build/sun50i_h616/release/bl31.bin /out/bl31.bin

FROM alpine AS build-uboot

RUN apk add --no-cache \
    make \
    clang \
    llvm \
    lld \
    bison \
    flex \
    python3 \
    python3-dev \
    py3-setuptools \
    swig \
    gcc-aarch64-none-elf \
    openssl-dev

COPY --from=src-uboot /usr/src/u-boot /usr/src/u-boot
COPY --from=build-trusted-firmware-a /out/bl31.bin /usr/src/u-boot/bl31.bin

WORKDIR /usr/src/u-boot

ENV BL31=/usr/src/u-boot/bl31.bin
ENV SCP=/dev/null
ENV HOSTCC=clang
ENV CC=clang
ENV CROSS_COMPILE=aarch64-none-elf-
ENV LD=ld.lld

COPY mangopi_mcore_defconfig /usr/src/u-boot/configs/mangopi_mcore_defconfig
COPY sun50i-h616-mangopi-mcore.dts /usr/src/u-boot/arch/arm/dts/sun50i-h616-mangopi-mcore.dts
RUN sed -i "s%sun50i-h616-orangepi-zero2.dtb \\\%sun50i-h616-orangepi-zero2.dtb \\\\\n\\tsun50i-h616-mangopi-mcore.dtb \\\%" /usr/src/u-boot/arch/arm/dts/Makefile
RUN make -j$(nproc) mangopi_mcore_defconfig
RUN make -j$(nproc)

RUN mkdir -p /out && cp u-boot-sunxi-with-spl.bin /out/u-boot-sunxi-with-spl.bin

FROM alpine

COPY --from=build-uboot /out/u-boot-sunxi-with-spl.bin /u-boot-sunxi-with-spl.bin

ENTRYPOINT [ "sh", "-c", "exec cp -v /u-boot-sunxi-with-spl.bin /out/" ]
