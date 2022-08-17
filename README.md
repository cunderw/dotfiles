**Setting Up a New Machine**

``` bash
git clone --separate-git-dir=$HOME/.dotfiles git@github.com:cunderw/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
```

***Java Development Setup***

Please run the following to have a better debugging and testing support for java

```
mkdir -p ~/workspace
git clone git@github.com:microsoft/java-debug.git ~/.config/lvim/.java-debug
cd ~/.config/lvim/.java-debug/
./mvnw clean install
git clone git@github.com:microsoft/vscode-java-test.git ~/.config/lvim/.vscode-java-test
cd ~/.config/lvim/.vscode-java-test
npm install
npm run build-plugin
```
