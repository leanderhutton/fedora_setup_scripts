#!/bin/sh
# 2022 leander@one-button.org
# it always comes back to shell scripts

DEFAULT_RPMS="thunderbird nextcloud-client quassel-client tmux vim htop vlc cmus keepassxc gimp vim-syntastic vim-fugitive"
PHOTO_RPMS="darktable rawtherapee"
GNOME_RPMS="gwenview ufraw" 
KDE_RPMS="rhythmbox kate"
NVIDIA_RPMS=""
ASTRONOMY_RPMS="stellarium skychart"
# figure out what DE is running
DESKTOP=$(echo $XDG_CURRENT_DESKTOP)

if  [[ $(groups | grep wheel) ]]; then
	echo "user has sudo"	
elif [ "$EUID" -eq 0 ]; then
	echo "user is root"
else
	echo "You are not root nor are you able to sudo"
	echo "Please remedy this and come back later"
	exit 1
fi

# Check for RPMFusion and enable
if compgen /etc/yum.repos.d/rpmfusion*.repo  > /dev/null; then
	echo "RPM Fusison already enabled"
else
	sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi

# some default actions to take on everything I want to use
sudo dnf -y upgrade
sudo dnf -y install $DEFAULT_RPMS $ASTRONOMY_RPMS

# Check for Zoom and install
if [ -f /usr/bin/zoom ]; then
	echo "Zoom already installed"
else
	# It's 2022 so install Zoom
	sudo rpm --import https://zoom.us/linux/download/pubkey
	sudo rpm -ivh https://zoom.us/client/latest/zoom_x86_64.rpm
fi

if [ "$DESKTOP" = "GNOME" ]; then

# RAW thubnails for GNOME
# and install some packages that GNOME Workstation needs
sudo dnf -y install $GNOME_RPMS
sudo bash -c 'cat > /usr/share/thumbnailers/ufraw.thumbnailer' <<EOF
[Thumbnailer Entry]
Exec=/usr/bin/ufraw-batch --embedded-image --out-type=png --size=%s %u --overwrite --silent --output=%o
MimeType=image/x-3fr;image/x-adobe-dng;image/x-arw;image/x-bay;image/x-canon-cr2;image/x-canon-crw;image/x-cap;image/x-cr2;image/x-crw;image/x-dcr;image/x-dcraw;image/x-dcs;image/x-dng;image/x-drf;image/x-eip;image/x-erf;image/x-fff;image/x-fuji-raf;image/x-iiq;image/x-k25;image/x-kdc;image/x-mef;image/x-minolta-mrw;image/x-mos;image/x-mrw;image/x-nef;image/x-nikon-nef;image/x-nrw;image/x-olympus-orf;image/x-orf;image/x-panasonic-raw;image/x-pef;image/x-pentax-pef;image/x-ptx;image/x-pxn;image/x-r3d;image/x-raf;image/x-raw;image/x-rw2;image/x-rwl;image/x-rwz;image/x-sigma-x3f;image/x-sony-arw;image/x-sony-sr2;image/x-sony-srf;image/x-sr2;image/x-srf;image/x-x3f;image/x-panasonic-raw2;image/x-nikon-nrw;
EOF

else
echo "NOT GNOME!"
fi
