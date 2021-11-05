**Setting Up a New Machine**

```
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:cunderw/dotfiles.git
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```
Once setup make sure to ignore untracked files so you don't see you're entire home folder.

```
dotfiles config --local status.showUntrackFiles no
```


