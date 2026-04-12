#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q srb2 | awk '{print $2; exit}') # example command to get version of application here
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

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# test the final app
quick-sharun --simple-test ./dist/*.AppImage
