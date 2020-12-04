#!/usr/bin/bash
cd /mnt/user/dotfiles 
find -type d -exec mkdir --parents -- /root/{} \;
find -type f -exec ln --symbolic -- /mnt/user/dotfiles/{} /root/{} \;
chsh -s $(which zsh)
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
