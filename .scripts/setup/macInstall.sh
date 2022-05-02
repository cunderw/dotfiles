#!/bin/bash

cd ~
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# brew packages
brew install neovim
brew install tmux
brew install ctags
brew install cmake3
brew install wget
brew install fzf
brew install bat
brew install navi

# casks
brew tap homebrew/cask-fonts
brew install --cask font-fira-mono-nerd-font

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# setup node 16
nvm install 16
nvm use 16

# python package installs
pip3 install pynvim

# ruby package installs
gem install colorls

bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
