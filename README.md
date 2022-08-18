## Setting Up a New Machine

### Installing Dotfiles
```shell
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:cunderw/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
dots submodule update --init --recuersive
```

### Install Scripts
WIP
```shell
~/.scripts/macInstall.sh
~/.scripts/macSetup.sh
```

### Recommended Fonts

- [FiraCode]: My preferred nerd font
- Any of the [Nerd Fonts]

On macOS with Homebrew, choose one of the [Nerd Fonts],
for example, here are some popular fonts:

```shell
brew tap homebrew/cask-fonts
brew search nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-victor-mono-nerd-font
brew install --cask font-iosevka-nerd-font-mono
brew install --cask font-hack-nerd-font
```

