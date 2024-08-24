setenv rootfstype "ext4"
setenv load_addr "0x45000000"
setenv fdt_addr "0x49000000"

setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p1 rootwait usb-storage.quirks=0x2537:0x1066:u,0x2537:0x1068:u
setenv param_spidev_spi_bus 1

load mmc 0 ${fdt_addr} boot/sun50i-h616-mangopi-mcore.dtb
fdt addr ${fdt_addr}
fdt resize 65536

load mmc 0 ${load_addr} boot/Image
booti ${load_addr} - ${fdt_addr}
