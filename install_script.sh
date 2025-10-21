#!/bin/sh
# Script install packages requirements, config files (with symlinks), font and Colors

DOTFILES=$HOME/.dotfiles
BACKUP_DIR=$HOME/dotfiles-backup

echo "=============================="
echo -e "\n\nBackup existing config ..."
echo "=============================="
echo "Creating backup directory at $BACKUP_DIR"
mkdir -p $BACKUP_DIR

# linkables=$( find -H "$DOTFILES" -maxdepth 3 -name '*.symlink' )
#
# # backup up any existing dotfiles in ~ and symlink new ones from .dotfiles
# for file in $linkables; do
#     filename=".$( basename $file '.symlink' )"
#     target="$HOME/$filename"
#     if [ -f $target ]; then
#         echo "backing up $filename"
#         cp $target $BACKUP_DIR
#     else
#         echo -e "$filename does not exist at this location or is a symlink"
#     fi
# done
#
# # backup from .config
# folders_to_backup=("borders" "alacritty")
#
# # Loop through each folder and back it up
# for folder in "${folders_to_backup[@]}"; do
#     original_folder="$HOME/.config/$folder"
#     backup_folder="${original_folder}_backup"
#
#     if [ -d "$original_folder" ]; then
#         mv "$original_folder" "$backup_folder"
#         echo "Backed up $folder to ${folder}_backup"
#     else
#         echo "Folder $folder does not exist, skipping..."
#     fi
# done

echo "=============================="
echo -e "\n\nInstalling packages ..."
echo "=============================="

package_to_install="neovim
    tree
    bash
    curl
    starship
    lazygit
    ripgrep
    fd
    dotnet
    jq
    gh
    tmux
"

echo "================================================="
echo "Symlink zsh theme, tmux.conf, zshrc"
echo "================================================="
echo "Symlinking dotfiles"
# ln -s -f $DOTFILES/bash/bashrc.symlink $HOME/.bashrc
ln -s -f $DOTFILES/bash/.bash_profile $HOME/.bash_profile
ln -s -f $DOTFILES/bash/.bashrc $HOME/.bashrc
# mkdir -p $HOME/.config/borders
# ln -s $DOTFILES/borders $HOME/.config/borders
# mkdir -p $HOME/.config/aerospace
# ln -s $DOTFILES/aerospace $HOME/.config/aerospace
# mkdir -p $HOME/.config/sketchybar
# ln -s $DOTFILES/sketchybar $HOME/.config/sketchybar
# mkdir -p $HOME/.config/nvim
ln -s $DOTFILES/nvim $HOME/.config/nvim
# mkdir -p $HOME/.config/alacritty
# ln -s $DOTFILES/alacritty $HOME/.config/alacritty
ln -s $DOTFILES/starship/starship.toml $HOME/.config/starship.toml

if uname -s | grep Darwin; then
  echo "================================================="
  echo "Installing packages $package_to_install on Mac OS"
  echo "================================================="
  brew update
  brew install $package_to_install
  echo "================================================="
  echo "Install hiddenbar & stats"
  echo "================================================="
  brew install --cask font-jetbrains-mono-nerd-font
  # brew install --cask alacritty
  brew install --cask hiddenbar
  brew install --cask stats
  brew install --cask sf-symbols
  # brew install --cask nikitabobko/tap/aerospace
  # brew tap FelixKratz/formulae
  # brew install sketchybar
  brew install --cask font-hack-nerd-font
  # brew services restart sketchybar
  brew install --cask dbeaver-community
  brew install --cask ghostty
else
  echo "OS NOT DETECTED, couldn't install package $package_to_install"
  exit 1
fi
