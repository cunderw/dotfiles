############################
# Environment Setup
############################
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export EDITOR='nvim'
export NVM_DIR="$HOME/.nvm"
export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin
export DISABLE_AUTO_TITLE=true
export PNPM_HOME="/Users/cunderw/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

############################
# Sourced Files / Utilities
############################
for f in ~/.scripts/sourced/*; do
  . $f
done

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f $HOME/.secrets ]] || source $HOME/.secrets

[[ ! -f $HOME/.cargo/env ]] || source $HOME/.cargo/env
source $HOME/.config/zsh_highlight_styles

############################
# Aliases
############################
alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias diskspace="du -S | sort -n -r | less"
alias logs="find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias dockspace="defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall Dock"
alias pullrepos="for i in */.git; do ( echo $i; cd $i/..; git pull; ); done"
alias glog="git log --all --decorate --oneline --graph"
alias dotsupdate="dotfiles pull && dotfiles submodule update"
alias zreload="exec zsh"
alias zconfig="vim ~/.zshrc"
alias lvim="$HOME/.local/bin/lvim"
alias up="cd $(eval printf '../'%.0s {1..$1}) && pwd;"
alias cls="colorls --dark"
eval $(thefuck --alias)

############################
# Antigen / Plugins
############################
# make sure we have zplug installed
if [[ ! -d ~/.zplug ]];then
    printf "Install zplug? [y/N]: "
    if read -q; then
        echo; git clone https://github.com/b4b4r07/zplug ~/.zplug
    fi
fi

if [[ -f $HOME/.zplug/init.zsh ]];then

  source $HOME/.zplug/init.zsh

  # oh-my-zsh
  zplug "plugins/colored-man-pages", from:oh-my-zsh
  zplug "plugins/command-not-found", from:oh-my-zsh
  zplug "plugins/common-aliases", from:oh-my-zsh
  zplug "plugins/copyfile", from:oh-my-zsh
  zplug "plugins/debian", from:oh-my-zsh
  zplug "plugins/docker", from:oh-my-zsh
  zplug "plugins/docker-compose", from:oh-my-zsh
  zplug "plugins/dotenv", from:oh-my-zsh
  zplug "plugins/git", from:oh-my-zsh
  zplug "plugins/go", from:oh-my-zsh
  zplug "plugins/jsontools", from:oh-my-zsh
  zplug "plugins/macOS", from:oh-my-zsh
  zplug "plugins/node", from:oh-my-zsh
  zplug "plugins/npm", from:oh-my-zsh
  zplug "plugins/nvm", from:oh-my-zsh
  zplug "plugins/pylint", from:oh-my-zsh
  zplug "plugins/python", from:oh-my-zsh
  zplug "plugins/systemd", from:oh-my-zsh
  zplug "plugins/thefuck", from:oh-my-zsh
  zplug "plugins/tmux", from:oh-my-zsh
  zplug "plugins/vscode", from:oh-my-zsh
  zplug "plugins/web-search", from:oh-my-zsh
  zplug "plugins/yarn", from:oh-my-zsh

  # others
  zplug "zsh-users/zsh-autosuggestions"
  zplug "zsh-users/zsh-completions"
  zplug "zsh-users/zsh-syntax-highlighting"

  zplug "so-fancy/diff-so-fancy", as:command
  # themes / appearance
  zplug "romkatv/powerlevel10k", as:theme

  if ! zplug check --verbose; then
      printf "Install Plugins? [y/N]: "
      if read -q; then
        echo; zplug install
      fi
  fi

  zplug load
fi

[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh



