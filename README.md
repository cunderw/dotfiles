**Setting Up a New Machine**

``` bash
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:cunderw/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```
