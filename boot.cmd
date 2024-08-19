setenv rootfstype "ext4"

load mmc 0 0x45000000 boot/Image
load mmc 0 0x49000000 boot/sun50i-h616-mangopi-mcore.dtb
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p1 rootwait usb-storage.quirks=0x2537:0x1066:u,0x2537:0x1068:u

booti 0x45000000 - 0x49000000