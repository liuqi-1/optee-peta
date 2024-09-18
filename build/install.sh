sudo rm -rf /media/liuqi/BOOT/*
sudo rm -rf /media/liuqi/ROOT/*
ls /media/liuqi/ROOT
ls /media/liuqi/BOOT
echo "finish clearing previous image"
cp images/BOOT.BIN /media/liuqi/BOOT
cp images/boot.scr /media/liuqi/BOOT
cp images/image.ub /media/liuqi/BOOT
sudo tar xvfp images/rootfs.tar.gz -C /media/liuqi/ROOT
echo "finish installing new boot image"