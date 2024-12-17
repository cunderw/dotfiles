#!/bin/bash

cd ~
# install brew

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/cunderw/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew packages
brew install neovim
brew install tmux
brew install wget
brew install fzf
brew install bat
brew install navi
brew install thefuck
brew install pnpm
brew install alt-tab
brew install fzf
brew install ripgrep
brew install lazygit

# casks
brew tap homebrew/cask-fonts
brew install --cask font-fira-mono-nerd-font

# apps
brew install --cask discord
