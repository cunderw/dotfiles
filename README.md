## Setting Up a New Machine

### Installing Dotfiles
```shell
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:cunderw/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
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

## Lunarvim Setup

### Prerequisites

- [Neovim](neovim-install) >= v0.6.0

```shell
  brew install neovim
```

- [NodeJS](nodejs-install) >= v16.13.0
  most language servers need this

```shell
brew install node
```

### GO Development Setup
TODO

### Java Development Setup

Please run the following to have a better debugging and testing support for java

```shell
mkdir -p ~/workspace
git clone git@github.com:microsoft/java-debug.git ~/.config/lvim/.java-debug
cd ~/.config/lvim/.java-debug/
./mvnw clean install
git clone git@github.com:microsoft/vscode-java-test.git ~/.config/lvim/.vscode-java-test
cd ~/.config/lvim/.vscode-java-test
npm install
npm run build-plugin
```
