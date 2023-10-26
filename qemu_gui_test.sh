#!/bin/bash

workdir=$(dirname $0)
echo "wokrdir: $workdir"

com=$1
test_suffix=""
nogui=""

if [ "$1" == "install" ]; then
	[ ! -f imx6ull-system-image.tar.xz ] && [ ! -f imx6ull-system-image/rootfs.img ] && wget https://github.com/konosubakonoakua/imx6ul_qemu/releases/download/system-image-v1/imx6ull-system-image.tar.xz
	[ ! -d imx6ull-system-image ] && tar -Jxvf imx6ull-system-image.tar.xz -C . && rm -f imx6ull-system-image.tar.xz
	deps=(libsdl2-dev libtinfo5 libncursesw5 libpython2.7)
	dpkg -s ${deps[*]} >/dev/null
	if [[ ! $? -eq 0 ]]; then
		sudo apt install ${deps[*]} || exit 1
	fi
	exit 0
fi

case "$1" in
fire)
	com=fire && echo "brd: fire"
	;;
atk)
	com=atk && echo "brd: atk"
	;;
100ask | *)
	com=100ask && echo "brd: 100ask"
	;;
esac

if [ "test" == "$2" ]; then
	test_suffix=_test
else
	echo "default: no test"
fi

if ["nogui" == "$3"]; then
	guicmd="-nographic"
	nogui=1
else
	guicmd="-show-cursor -display sdl -com $com"
	nogui=""
	echo "default: with gui"
fi

$workdir/qemu/bin/qemu-system-arm -M mcimx6ul-evk $guicmd -m 512M -kernel $workdir/imx6ull-system-image/zImage$test_suffix \
	-dtb $workdir/imx6ull-system-image/100ask_imx6ull_qemu$test_suffix.dtb \
	-serial mon:stdio -nic user \
	-drive file=$workdir/imx6ull-system-image/rootfs.img,format=raw,id=mysdcard -device sd-card,drive=mysdcard \
	-append "console=ttymxc0,115200 rootfstype=ext4 root=/dev/mmcblk1 rw rootwait init=/sbin/init loglevel=8"
