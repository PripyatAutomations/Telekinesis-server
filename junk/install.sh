#!/bin/bash
[ ! -f /opt/netrig/etc/config.sh ] && {
   echo "* Please put this stuff at /opt/netrig/ and make sure etc/config.sh exists"
   exit 1
}

. /opt/netrig/etc/config.sh

echo "* updating submodules..."
git submodule init
git submodule pull

echo "* Installing host packages (apt)"
# remove this temporarily XXX: Fix pipewire stuff ASAP
sudo apt purge pipewire pipewire-alsa pipewire-bin pipewire-audio-client-libraries pipewire-jack pipewire-pulse pipewire-v4l2  pipewire-doc wireplumber
# install stuff
sudo apt install espeak-ng libespeak-ng-dev libsamplerate-dev libsamplerate0 sox ffmpeg
sudo apt install libhttp-request-params-perl libio-async-loop-epoll-perl libnet-async-http-perl libjson-perl libdata-dumper-simple-perl libhamlib-perl librpc-xml-perl
sudo apt install asterisk asterisk-core-sounds-en asterisk-flite asterisk-dev asterisk-modules baresip baresip-ffmpeg 

echo "* Installing cpan bits"
sudo cpan -i Number::Spell

echo "* building needed components..."
# Build chan_sccp-b to support cisco devices better

echo "=> chan_sccp-b..."
/opt/netrig/ext/build-chan-sccp.sh

# build ardop modems
echo "=> ardop modems..."
/opt/netrig/ext/build-ardop.sh

# patch novnc so we can send passwords via url
[ ! -f /opt/netrig/ext/.novnc_patched ] && {
   echo "! patching noVNC to allow passing password in URL..."
   cd /opt/netrig/ext/noVNC
   patch -p1<../noVNC-password-in-url.patch
   touch /opt/netrig/ext/.novnc_patched
   cd -
}

[ ! -s /usr/share/asterisk/sounds/netrig ] && {
   ln -s /opt/netrig/voices /usr/share/asterisk/sounds/netrig
}

[ ! -L /usr/share/asterisk/agi-bin/netrig ] && {
   ln -s /opt/netrig/agi-bin /usr/share/asterisk/agi-bin/netrig
}

echo "* Fixing permissions..."
sudo chown -R ${NETRIG_HOST_USER}:${NETRIG_HOST_GROUP} /opt/netrig
sudo chown -R asterisk:${NETRIG_HOST_GROUP} /opt/netrig/etc/asterisk

echo "* Adding to PATH (profile.d)"
echo "export PATH=\$PATH:/opt/netrig/bin" >> /etc/profile.d/netrig.sh

echo "* Fetching dark theme..."
/opt/netrig/install/tasks/fetch-dark-gtk-theme

echo "* Installing homedir files to ${NETRIG_HOST_USER}"
/opt/netrig/install/tasks/install-homedir

echo "* Building voices (if needed)"
/opt/netrig/voices/build-all-voices.sh

echo "**** Install Done ****"
