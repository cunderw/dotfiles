############################
# Environment Setup
############################
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export EDITOR='nvim'
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"


############################
# Setup antigen and plugins
############################
source $HOME/.antigen.zsh

antigen use oh-my-zsh

# oh-my-zsh
antigen bundle git
antigen bundle yarn
antigen bundle web-search
antigen bundle jsontools
antigen bundle node
antigen bundle npm
antigen bundle sudo
antigen bundle docker
antigen bundle tmux
antigen bundle command-not-found
antigen bundle common-aliases
antigen bundle copyfile
antigen bundle debian
antigen bundle macOS
antigen bundle sudo
antigen bundle systemd
antigen bundle vscode
antigen bundle zsh-interactive-cd
antigen bundle colored-man-pages

# others
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle arzzen/calc.plugin.zsh


antigen theme romkatv/powerlevel10k

antigen apply

############################
# aliass
############################
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias diskspace="du -S | sort -n -r | less"
alias logs="find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias dockspace="defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall Dock"
alias pullrepos="for i in */.git; do ( echo $i; cd $i/..; git pull; ); done"
alias glog="git log --all --decorate --oneline --graph"
alias dotsupdate="dotfiles pull && dotfiles submodule update"
alias zreload="source ~/.zshrc"
alias zconfig="vim ~/.zshrc"
alias vim="nvim"

############################
# Utilities
############################
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
