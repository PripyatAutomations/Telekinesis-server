#!/bin/bash
#
# This script will fetch all the various bits
##
# Don't even try it yet.. It's definitely NOT ready, as it hasn't been fully merged - 20231112
CACHEDIR=/home/cache

function error {
   echo "Error! $1"
   exit 3
}

echo "*******************************************"
echo "* Make sure USB stick is mounted at /mnt! *"
echo "*******************************************"
echo ""
echo "Press CTRL-C (^C) now to abort or enter to proceed"
read line

#[ -d /mnt/opt/netrig ] && {
#   echo "* Existing netrig install found at /mnt/opt/netrig, bailing!"
#   exit 1
#}

mountpoint /mnt
[  $? -ne 0 ] && {
  echo "* /mnt is not a mountpoint, bailing!"
  exit 2
}
mkdir -p ${CACHEDIR}/deb

[ ! -d /opt/netrig ] && {
   mkdir -p /opt
   cd /opt
   git clone https://github.com/PripyatAutomations/netrig.git
}

[ ! -f /mnt/etc/passwd ] && {
   echo "* Preparing chroot..."
   debootstrap --cache-dir=${CACHEDIR}/deb testing /mnt || error "debootstrap"
}

echo "* rsyncing deboostrap cache into chroot..."
rsync -avrx ${CACHEDIR}/deb/*.deb /mnt/var/cache/apt/archives/

mountpoint /mnt/dev 1>/dev/null
[ $? -ne 0 ] && {
   for i in proc dev dev/pts sys; do
      mount --bind /$i /mnt/$i
   done
}

echo "* Adding resolv.conf"
echo "nameserver 1.1.1.1" > /mnt/etc/resolv.conf
echo "nameserver 8.8.8.8" >> /mnt/etc/resolv.conf
echo "nameserver 9.9.9.9" >> /mnt/etc/resolv.conf

[ ! -f /mnt/opt/remotpi/etc/config.sh ] && {
   mkdir -p /mnt/opt/
   echo "* Copying netrig tree..."
   cp -avrx /opt/netrig/ /mnt/opt/
}

echo "apt install git sudo" > /mnt/tmp/stage1.5
echo "useradd -r -m" >> /mnt/tmp/stage1.5
echo "/opt/netrig/install/install.sh" >> /mnt/tmp/stage1.5
chmod 0755 /mnt/tmp/stage1.5
chroot /mnt /tmp/stage1.5

for i in proc dev dev/pts sys; do
   umount /mnt/$i
done

echo "* rsyncing chroot dpkg cache into debootstrap cache..."
rsync -avrx /mnt/var/cache/apt/archives/*.deb ${CACHEDIR}/deb/
