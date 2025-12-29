#!/bin/sh

# cargo install spotify_player --no-default-features  --features "pulseaudio-backend,image,notify,daemon"
yay -S spotify spicetify-cli spicetify-themes-git

sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R

spicetify config current_theme Ziro
spicetify config color_scheme rose-pine-moon
spicetify backup apply
spicetify apply
