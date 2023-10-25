[ ! -f qemu.tar.xz ] && wget https://github.com/konosubakonoakua/imx6ul_qemu/releases/download/qemu_v1/qemu.tar.xz
[ ! -d qemu ] && tar -Jxvf qemu.tar.xz -C . && rm -f qemu.tar.xz
