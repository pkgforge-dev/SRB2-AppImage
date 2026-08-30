#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q srb2 | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://git.do.srb2.org/STJr/SRB2/-/raw/next/srb2.png?ref_type=heads
export DESKTOP=/usr/share/applications/srb2-opengl.desktop
export APPNAME="Sonic Robo Blast 2"
export STARTUPWMCLASS=srb2
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun /usr/bin/srb2

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the app normally quits before that time
# then skip this or check if some flag can be passed that makes it stay open
quick-sharun --simple-test ./dist/*.AppImage
