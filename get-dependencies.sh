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
VERSION="$(curl -sL https://api.github.com/repos/STJr/SRB2/releases/latest | grep '"tag_name"' | head -1 | cut -d '"' -f 4)"
git clone --branch "$VERSION" "$REPO" ./SRB2
VERSION_NOV="${VERSION#v}"
echo "$VERSION_NOV" > ~/version

# Assets zip from same latest tag
curl -L -o SRB2-v2215-Full.zip \
  "https://github.com/STJr/SRB2/releases/download/SRB2_release_$VERSION/SRB2-v2215-Full.zip"

mkdir -p ./AppDir/bin
mkdir -p ./AppDir/share/games/SRB2
bsdtar -xvf SRB2-v2215-Full.zip -C ./AppDir/share/games/SRB2

cd ./SRB2/src

export CXXFLAGS="${CXXFLAGS:-} -Wp,-U_GLIBCXX_ASSERTIONS"
cmake -G Ninja -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-g1 -O3" \
    -DCMAKE_CXX_FLAGS=-"g1 -O3 -fpermissive" \
    -DSRB2_CONFIG_DEV_BUILD=OFF \
    -DSRB2_SDL2_EXE_NAME=ringracers \
    -DACSVM_INSTALL_LIB=OFF
cmake --build build -j$(nproc)
mv -v build/bin/ringracers ../AppDir/bin
