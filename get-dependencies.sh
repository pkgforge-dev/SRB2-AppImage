#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    glu        \
    libgme     \
    libopenmpt \
    miniupnpc  \
    sdl2_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

echo "Building stable version of Sonic Robo Blast 2..."
echo "---------------------------------------------------------------"
REPO="https://github.com/STJr/SRB2"
RELEASE="$(curl -fsSL https://api.github.com/repos/STJr/SRB2/releases/latest)"
TAG="$(echo "$RELEASE" | grep '"tag_name"' | head -1 | cut -d '"' -f 4)"
FULL_ZIP_URL="$(echo "$RELEASE" | grep '"browser_download_url"' | grep -- '-Full\.zip' | head -1 | cut -d '"' -f 4)"
git clone --branch "$TAG" "$REPO" ./SRB2
VERSION="${TAG#SRB2_release_}"
echo "$VERSION" > ~/version

curl -fL -O "$FULL_ZIP_URL"
FULL_ZIP="$(basename "$FULL_ZIP_URL")"

mkdir -p ./AppDir/bin
mkdir -p ./AppDir/share/games/SRB2
bsdtar -xf "$FULL_ZIP" -C ./AppDir/share/games/SRB2 \
    models.dat music.pk3 srb2.pk3 zones.pk3 characters.pk3
if bsdtar -xf "$FULL_ZIP" -C ./AppDir/share/games/SRB2 patch.pk3 2>/dev/null; then
    echo "patch.pk3 found and installed"
else
    echo "patch.pk3 not found, continuing without it"
fi
rm -f "$FULL_ZIP"

cd ./SRB2/src
# make comptime.sh optional
sed 's/^comptime\.c ::/comptime.c :/' -i Makefile
# use better version string
sed 's/-DCOMPVERSION//' -i Makefile
sed 's/illegal/AUR/' -i comptime.c

make LINUX64=1 NOUPX=1 NOVERSION=1 CFLAGS="-std=gnu11" -j$(nproc)
mv -v ../bin/lsdl2srb2 ../../AppDir/bin/srb2
