[ ! -f qemu.tar.xz ] && [ ! -x qemu/bin/qemu-arm ] && wget https://github.com/konosubakonoakua/imx6ul_qemu/releases/download/qemu_v1/qemu.tar.xz
[ ! -d qemu ] && tar -Jxvf qemu.tar.xz -C . && rm -f qemu.tar.xz
deps=(libsdl2-dev)
dpkg -s ${deps[*]} >/dev/null
if [[ ! $? -eq 0 ]]; then
	sudo apt install ${deps[*]} || exit 1
fi
exit 0
