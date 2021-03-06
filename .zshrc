export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export ZSH=$HOME/.oh-my-zsh
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# plugins
plugins=(
  git
  yarn
  web-search
  jsontools
  node
  sudo
  thor
  docker
  tmux
  command-not-found
  common-aliases
  copyfile
  debian
  httpie
  jira
  node
  npm
  osx
  sudo
  systemd
  vscode
  wd
)
source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'

# aliass
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias diskspace="du -S | sort -n -r | less"
alias logs="find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias dockspace="defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall Dock"
alias pullrepos="for i in */.git; do ( echo $i; cd $i/..; git pull; ); done"
alias glog="git log --all --decorate --oneline --graph"
alias dotsupdate="dotfiles pull && dotfiles submodule update"
alias zreload="source ~/.zshrc"
alias zconfig="vim ~/.zshrc"

# expand aliases with tab
zstyle ':completion:*' completer _expand_alias _complete _ignored
# functions and other sources
# Easy way to extract archives
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1;;
           *.tar.gz)    tar xvzf $1;;
           *.bz2)       bunzip2 $1 ;;
           *.rar)       unrar x $1 ;;
           *.gz)        gunzip $1  ;;
           *.tar)       tar xvf $1 ;;
           *.tbz2)      tar xvjf $1;;
           *.tgz)       tar xvzf $1;;
           *.zip)       unzip $1   ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1;;
           *) echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
}

# Move 'up' so many directories instead of using several cd ../../, etc.
up() { cd $(eval printf '../'%.0s {1..$1}) && pwd; }

source ~/scripts/sourced/goto.sh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh-vim-mode/zsh-vim-mode.plugin.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
