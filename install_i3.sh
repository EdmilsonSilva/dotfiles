#!/usr/bin/env bash

read -p "Do you want to proceed installing i3? (y/N) " yn
case $yn in
  [Yy]* ) echo "Proceeding with the instalation";;
  * ) echo "Exiting";
    exit;;
esac

if ! command -v i3 &> /dev/null; then
 echo 'Installing i3'
 sudo apt install i3 -y
fi

echo 'Configuring i3 and creating symlink'
check if .config/nvim folder exists before creating symlink
if [ -d ~/.config/i3 ]; then
 mv ~/.config/i3{,.bkp}
fi

check if .config/nvim still exists, if not create symlink
if [ ! -a ~/.config/i3 ]; then
 ln -s $DOTFILES_PATH/i3 $HOME/.config/i3
fi