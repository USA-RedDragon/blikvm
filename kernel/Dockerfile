FROM alpine AS src

RUN apk add --no-cache \
    git

WORKDIR /usr/src

# renovate: datasource=git-tags depName=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
ARG LINUX_VERSION=v6.10.6

RUN git clone --branch ${LINUX_VERSION} --depth 1 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
RUN cd linux && TZ=UTC git show -s --date=format-local:'%Y-%m-%d %H:%M:%S' --format=%cd HEAD > .kernel-version

FROM alpine AS linux-firmware-src

# renovate: datasource=git-tags depName=https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
ARG LINUX_FIRMWARE_VERSION=20240811

RUN apk add --no-cache \
    git

WORKDIR /usr/src

RUN git clone --branch ${LINUX_FIRMWARE_VERSION} --depth 1 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git

FROM alpine AS build

RUN apk add --no-cache \
    make \
    clang \
    bison \
    flex \
    lld \
    cpio \
    linux-headers \
    openssl-dev \
    llvm \
    findutils \
    coreutils \
    perl \
    openssl \
    python3 \
    zstd \
    tar \
    xz \
    rsync \
    patch

COPY --from=src /usr/src/linux /usr/src/linux
COPY 0001-arm64-dts-sun50i-h616-add-emac1-node.patch /usr/src/linux/0001-arm64-dts-sun50i-h616-add-emac1-node.patch
COPY 0002-drv-net-stmmac-dwmac-sun8i-second-EMAC-clock-registe.patch /usr/src/linux/0002-drv-net-stmmac-dwmac-sun8i-second-EMAC-clock-registe.patch
COPY 0003-mfd-ax20x-Add-suppport-for-AXP1530-PMIC.patch /usr/src/linux/0003-mfd-ax20x-Add-suppport-for-AXP1530-PMIC.patch
RUN patch -p1 -d /usr/src/linux < /usr/src/linux/0001-arm64-dts-sun50i-h616-add-emac1-node.patch
RUN patch -p1 -d /usr/src/linux < /usr/src/linux/0002-drv-net-stmmac-dwmac-sun8i-second-EMAC-clock-registe.patch
RUN patch -p1 -d /usr/src/linux < /usr/src/linux/0003-mfd-ax20x-Add-suppport-for-AXP1530-PMIC.patch

COPY sun50i-h616-mangopi-mcore.dts /usr/src/linux/arch/arm64/boot/dts/allwinner/sun50i-h616-mangopi-mcore.dts
RUN echo "dtb-\$(CONFIG_ARCH_SUNXI) += sun50i-h616-mangopi-mcore.dtb" >> /usr/src/linux/arch/arm64/boot/dts/allwinner/Makefile

WORKDIR /usr/src/linux

ENV ARCH=arm64
ENV LLVM=1
ENV KBUILD_BUILD_VERSION=0
ENV KBUILD_BUILD_USER=linux
ENV KBUILD_BUILD_HOST=linux

COPY kernel.config .config

RUN export KBUILD_BUILD_TIMESTAMP=$(cat .kernel-version) \
    && make -j$(nproc) Image dtbs modules \
    && mkdir -p /out/modules \
    && mkdir -p /out/headers \
    && make -j$(nproc) INSTALL_MOD_PATH=/out/modules modules_install \
    && make -j$(nproc) INSTALL_HDR_PATH=/out/headers headers_install \
    && cp arch/arm64/boot/Image /out/Image \
    && cp .config /out/config \
    && cp arch/arm64/boot/dts/allwinner/sun50i-h616-mangopi-mcore.dtb /out/sun50i-h616-mangopi-mcore.dtb

FROM alpine

COPY --from=build /out /built
RUN mkdir -p /built/firmware
RUN mkdir -p /built/firmware/rtw88
RUN mkdir -p /built/firmware/rtl_bt
COPY --from=linux-firmware-src /usr/src/linux-firmware/rtw88/rtw8723d_fw.bin /built/firmware/rtw88/rtw8723d_fw.bin
COPY firmware/rtl_bt /built/firmware/rtl_bt

ENTRYPOINT [ "sh", "-c", "exec cp -r -v /built/* /out" ]
