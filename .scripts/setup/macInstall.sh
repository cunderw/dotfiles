#!/bin/bash

cd ~
# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/cunderw/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew packages
brew install neovim
brew install tmux
brew install wget
brew install fzf
brew install bat
brew install navi
brew install thefuck

# casks
brew tap homebrew/cask-fonts
brew install --cask font-fira-mono-nerd-font

# install nvm
/bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh)" 

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# setup node 16
nvm install 16
nvm use 16

# python package installs
pip3 install pynvim

# ruby package installs
gem install colorls

bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
