**Setting Up a New Machine**

```
git clone --separate-git-dir=$HOME/.dotfiles git@gitlab.com:cunderw/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```



