PROJ=lora
obj-m := $(PROJ).o

ifeq ($(KERNELDIR),)
KERNELDIR=/lib/modules/$(shell uname -r)/build
endif

OVERLAY_SRC=rpi-lora-spi-overlay.dts
OVERLAY_DST=/boot/overlays/rpi-lora-spi.dtbo

all:
	make -C $(KERNELDIR) M=$(shell pwd) modules

dts:
	sudo dtc -I dts -O dtb -@ -o $(OVERLAY_DST) $(OVERLAY_SRC)

install:
	gzip lora.ko
	sudo mv lora.ko.gz /lib/modules/$(shell uname -r)/kernel/drivers/spi/rpi-lora-spi.ko.gz

test-pre:
	sudo insmod ./$(PROJ).ko
	dmesg | tail
	cat /sys/class/$(PROJ)/$(PROJ)/dev
	cat /sys/class/$(PROJ)/$(PROJ)/uevent
	sudo chmod 666 /dev/$(PROJ)
	ls -l /dev/$(PROJ)
	#cc test-application/main.c -o ioctl

test-action:
	#cat /dev/$(PROJ)
	#dmesg | tail -n 40
	#echo Happy! > /dev/$(PROJ)
	#dmesg | tail -n 40
	#./ioctl /dev/$(PROJ) GET
	#./ioctl /dev/$(PROJ) SET 2
	#./ioctl /dev/$(PROJ) GET
	#dmesg | tail
	#cat /dev/$(PROJ)
	#dmesg | tail -n 40
	#echo GoGoGoGoGoGo! > /dev/$(PROJ)
	#dmesg | tail -n 40
	#cat /dev/$(PROJ)
	#dmesg | tail -n 40

test-post:
	sudo rmmod $(PROJ)
	dmesg | tail

test: test-pre test-action test-post

clean:
	make -C $(KERNELDIR) M=$(shell pwd) clean
	rm -f ioctl
