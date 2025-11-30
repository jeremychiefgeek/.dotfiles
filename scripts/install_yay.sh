#!/bin/sh

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git  ~/yay-bin && cd ~/yay-bin && makepkg -si
