sudo rm -rf /media/liuqi/BOOT/*
sudo rm -rf /media/liuqi/ROOT/*
ls /media/liuqi/ROOT
ls /media/liuqi/BOOT
echo "finish clearing previous image"
cp BOOT.bin /media/liuqi/BOOT
cp boot.scr /media/liuqi/BOOT
cp image.ub /media/liuqi/BOOT
sudo tar -xvf rootfs.tar -C /media/liuqi/ROOT >/dev/null 2>&1
echo "finish installing new boot image"