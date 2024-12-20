# Enable p10k-instant-prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

############################
# Environment Setup
############################
export DISABLE_AUTO_TITLE=true
export EDITOR='nvim'
#export JAVA_HOME=~/.java/jdk-18.0.2.1+1/Contents/Home
export LANG=en_US.UTF-8
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export NVM_DIR=$HOME/.nvm
export PNPM_HOME=$HOME/Library/pnpm
export TERM="xterm-256color"
export ZPLUG_HOME=$HOME/.zplug
export NPM_TOKEN=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
export PATH="$PATH":"$HOME/.pub-cache/bin"

# GO
export GOPATH=$HOME/go

# Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

# PATH
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$GOPATH/bin
export PATH=$PNPM_HOME:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:$HOME/.cargo/bin:$PATH
export PATH=$PATH:$HOME/flutter/bin

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history

############################
# Plugin Settings
############################
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ENABLE_CORRECTION="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE="true"

############################
# Sourced Files / Utilities
############################
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then

  for f in ~/.scripts/sourced/*; do
      . $f
  done
  
  [[ ! -f $HOME/.secrets ]] || source $HOME/.secrets
  [[ ! -f $HOME/.cargo/env ]] || source $HOME/.cargo/env
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  
  eval "$(rbenv init - zsh)"
  
  # fix nvim breaking cursor
  _fix_cursor() {
      echo -ne '\e[5 q'
  }
  
  precmd_functions+=(_fix_cursor)
  
  ############################
  # Aliases
  ############################
  alias cls="colorls --dark"
  alias diskspace="du -S | sort -n -r | less"
  alias dockspace="defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'; killall Dock"
  alias dots="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
  alias dotsupdate="dotfiles pull && dotfiles submodule update"
  alias glog="git log --all --decorate --oneline --graph"
  alias gprune="git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D"
  alias grep="grep --color=auto"
  alias l="ls --color=auto"
  alias la="ls -lah --color=auto"
  alias lh="ls -lh --color=auto"
  alias logs="find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
  alias ls="ls --color=auto"
  alias pullrepos="for i in */.git; do ( echo $i; cd $i/..; git pull; ); done"
  alias up="cd $(eval printf '../'%.0s {1..$1}) && pwd;"
  alias zconfig="vim ~/.zshrc"
  alias zreload="exec zsh"
  alias npmt="npm run test"
  
  ############################
  # Plugins
  ############################
  # make sure we have zplug installed
  if [[ ! -d $HOME/.zplug ]];  then
      printf 'Install zplug? [y/N]: '
      if read -q; then
          echo; git clone https://github.com/b4b4r07/zplug ~/.zplug
      fi
  fi
  
  if [[ -f $HOME/.zplug/init.zsh ]]; then
  
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
      zplug "plugins/flutter", from:oh-my-zsh
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
      # zplug "plugins/yarn", from:oh-my-zsh
  
      # prezto
      zplug "modules/completion", from:prezto
      zplug "modules/directory",  from:prezto
  
      # commands
      zplug "so-fancy/diff-so-fancy", as:command
  
      # zsh users
      zplug "zsh-users/zsh-autosuggestions",          defer:2, on:"zsh-users/zsh-completions"
      zplug "zsh-users/zsh-syntax-highlighting",      defer:3, on:"zsh-users/zsh-autosuggestions"
      zplug "zsh-users/zsh-history-substring-search", defer:3, on:"zsh-users/zsh-syntax-highlighting"
  
      # utils
      zplug "jeffreytse/zsh-vi-mode"
  
      # themes / appearance
      zplug "romkatv/powerlevel10k", as:theme
  
      if ! zplug check --verbose; then
          printf 'Install Plugins? [y/N]: '
          if read -q; then
              echo; zplug install
          fi
      fi
  
      zplug load
  
  fi
  
  #############################
  # Keybindings
  ############################
  # Keybindings for substring search plugin. Maps up and down arrows.
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  
  # ctrl+p and ctrl+n for previous next
  bindkey "^P" history-substring-search-up
  bindkey "^N" history-substring-search-down
  
  # ctrl+space to accept the auto suggestion
  bindkey '^ ' autosuggest-accept
  
  # fix zsh bug where backspace breaks after exiting insert mode
  bindkey "^?" backward-delete-char
  
  # fix home and end keys
  bindkey "^[[1~" beginning-of-line
  bindkey "^[[4~" end-of-line
  
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi
