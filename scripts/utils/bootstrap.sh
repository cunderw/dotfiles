#!/usr/bin/bash
cd /boot/config/dotfiles
find -type d -exec mkdir --parents -- /root/{} \;
find -type f -exec ln --symbolic -- /boot/config/dotfiles/{} /root/{} \;
chsh -s $(which zsh)
