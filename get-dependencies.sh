#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    glu        \
    libopenmpt \
    miniupnpc  \
    sdl2_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
sed -i -e 's|-O2|-O2 -std=gnu11|' /etc/makepkg.conf
#make-aur-package srb2-data
#make-aur-package srb2

# If the application needs to be manually built that has to be done down here

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
echo "Building stable version of Sonic Robo Blast 2..."
echo "---------------------------------------------------------------"
REPO="https://github.com/STJr/SRB2"
#VERSION="$(curl -sL https://api.github.com/repos/STJr/SRB2/releases/latest | grep '"tag_name"' | head -1 | cut -d '"' -f 4)"
#git clone --branch "$VERSION" "$REPO" ./SRB2
#VERSION_NOV="${VERSION#v}"
#echo "$VERSION_NOV" > ~/version

# Assets zip from same latest tag
#curl -L -o SRB2-v2215-Full.zip \
#  "https://github.com/STJr/SRB2/releases/download/SRB2_release_$VERSION/SRB2-v2215-Full.zip"

RELEASE="$(curl -fsSL https://api.github.com/repos/STJr/SRB2/releases/latest)"
TAG="$(echo "$RELEASE" | grep '"tag_name"' | head -1 | cut -d '"' -f 4)"
FULL_ZIP_URL="$(echo "$RELEASE" | grep '"browser_download_url"' | grep -- '-Full\.zip' | head -1 | cut -d '"' -f 4)"
git clone --branch "$VERSION" "$REPO" ./SRB2
VERSION="${TAG#SRB2_release_}"
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
mkdir -p ./AppDir/share/games/SRB2
# Assets zip from same latest tag
bsdtar -xf "$FULL_ZIP" -C ./AppDir/share/games/SRB2 \
    models.dat music.pk3 srb2.pk3 zones.pk3 characters.pk3
# patch.pk3 install it only when present, otherwise just carry on
if bsdtar -xf "$FULL_ZIP" -C ./AppDir/share/games/SRB2 patch.pk3 2>/dev/null; then
    echo "patch.pk3 found and installed"
else
    echo "patch.pk3 not found, continuing without it"
fi


#bsdtar -xvf SRB2-v2215-Full.zip 
#models.dat {music,srb2,zones,characters}.pk3 -C ./AppDir/share/games/SRB2
#if test -f "patch.pk3"; then install -m644 patch.pk3 ./AppDir/share/games/SRB2; fi

cd ./SRB2/src
# make comptime.sh optional
sed 's/^comptime\.c ::/comptime.c :/' -i Makefile
# use better version string
sed 's/-DCOMPVERSION//' -i Makefile
sed 's/illegal/AUR/' -i comptime.c

make LINUX64=1 NOUPX=1 NOVERSION=1 -j$(nproc)
mv -v ../bin/lsdl2srb2 ../../AppDir/bin/srb2
