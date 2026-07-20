# Enable p10k-instant-prompt
# (disabled while testing starship as the prompt; uncomment to go back to p10k)
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#     source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

############################
# Environment Setup
############################
export DISABLE_AUTO_TITLE=true
export EDITOR='nvim'
export LANG=en_US.UTF-8
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export NVM_DIR=$HOME/.nvm
export PNPM_HOME=$HOME/Library/pnpm
export TERM="xterm-256color"
# Some oh-my-zsh plugins (git, npm, tmux, macos, flutter) expect this to be
# set by the full framework, which we don't load - provide it ourselves.
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"


# GO
export GOPATH=$HOME/go

# Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

# Path
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$GOPATH/bin
export PATH=$PNPM_HOME:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:$HOME/.cargo/bin:$PATH
export PATH=$PATH:$HOME/flutter/bin
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"

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

#for f in ~/.scripts/sourced/*; do
#    . $f
#done

[[ ! -f $HOME/.secrets ]] || source $HOME/.secrets
[[ ! -f $HOME/.cargo/env ]] || source $HOME/.cargo/env
# Lazy-load nvm: sourcing nvm.sh eagerly runs its own nvm_auto hook on every
# shell startup (~300-400ms) even when node isn't used. Defer that cost to the
# first actual nvm/node/npm/npx call in a given shell.
_nvm_lazy_load() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
for _nvm_cmd in nvm node npm npx; do
    eval "${_nvm_cmd}() { _nvm_lazy_load; ${_nvm_cmd} \"\$@\"; }"
done
unset _nvm_cmd

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
alias ftest='flutter test | grep -F "[E]"'
alias icerts="xcrun simctl keychain booted add-root-cert '/Library/Application Support/Netskope/STAgent/data/nscacert.pem'"
alias cc=claude
alias ccc='claude --continue'
alias ccd='claude --dangerously-skip-permissions'
alias ccr='claude --resume'
############################
# Plugins
############################
# compdef (needed by several oh-my-zsh plugins below) comes from compinit.
# Skip the compaudit security scan unless the dump is more than a day old,
# so this stays cheap on every shell.
autoload -Uz compinit
_zcompdump="$ZSH_CACHE_DIR/zcompdump"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"
else
    compinit -C -d "$_zcompdump"
fi
unset _zcompdump

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

# Static loading: only recompile the bundle when the plugin list changes,
# otherwise just source the pre-built (fast) plugin file.
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# powerlevel10k disabled while testing starship as the prompt; to go back,
# add `romkatv/powerlevel10k` to ~/.zsh_plugins.txt

#############################
# Keybindings
############################
bindkey -v
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
# Disabled while testing starship; uncomment to go back to p10k.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

############################
# Starship prompt
############################
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
else
    printf 'starship not found. Install via Homebrew? [y/N]: '
    if read -q; then
        echo; brew install starship && eval "$(starship init zsh)"
    fi
    echo
fi


[[ -f /Users/underwoc/.dart-cli-completion/zsh-config.zsh ]] && . /Users/underwoc/.dart-cli-completion/zsh-config.zsh || true
