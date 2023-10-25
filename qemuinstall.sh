[ ! -f qemu.tar.xz ] && wget https://github.com/konosubakonoakua/imx6ul_qemu/releases/download/qemu_v1/qemu.tar.xz
[ ! -d qemu ] && tar -Jxvf qemu.tar.xz -C . && rm -f qemu.tar.xz

deps=(libsdl2-dev)
dpkg -s ${deps[*]} >/dev/null
[[ ! $? -eq 0 ]] && sudo apt install ${deps[*]}
