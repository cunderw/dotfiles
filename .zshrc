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

for f in ~/.scripts/sourced/*; do
    . $f
done

[[ ! -f $HOME/.cargo/env ]] || source $HOME/.cargo/env

# nvm setup
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 

# ruby setup
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
alias zconfig="nvim ~/.zshrc"
alias zreload="exec zsh"
alias npmt="npm run test"
alias ftest='flutter test | grep -F "[E]"'
# With no args, name the session "<project>" or "<project> (<branch>)" off main.
claude() {
  if (( $# == 0 )); then
    local common project branch
    common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if [[ -n $common ]]; then
      project=${common:h:t}
      branch=$(git branch --show-current 2>/dev/null)
    else
      project=${PWD:t}
    fi
    local name=$project
    [[ -n $branch && $branch != main && $branch != master ]] && name="$project ($branch)"
    command claude --model opus --name "$name"
  else
    command claude --model opus "$@"
  fi
}
alias cc=claude
alias ccc='claude --continue'
alias ccd='claude --dangerously-skip-permissions'
alias ccr='claude --resume'
alias awdl='sudo ifconfig awdl0 down && sudo ifconfig awdl0 up'

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

_antidote_path=/opt/homebrew/opt/antidote/share/antidote/antidote.zsh
if [[ ! -f $_antidote_path ]]; then
    printf 'antidote not found. Install via Homebrew? [y/N]: '
    if read -q; then
        echo; brew install antidote
    fi
    echo
fi

if [[ -f $_antidote_path ]]; then
    source $_antidote_path

    # Static loading: only recompile the bundle when the plugin list changes,
    # otherwise just source the pre-built (fast) plugin file.
    zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
    # Clones live in ~/Library/Caches/antidote, which cache cleaners can wipe.
    # Rebuild (and re-clone) if any file the bundle sources is gone.
    _antidote_missing=0
    if [[ -f ${zsh_plugins}.zsh ]]; then
        for _antidote_line in ${(M)${(f)"$(<${zsh_plugins}.zsh)"}:#source *}; do
            _antidote_file=${(Q)${_antidote_line#source }}
            [[ -f ${_antidote_file/\$HOME/$HOME} ]] || { _antidote_missing=1; break }
        done
    fi
    if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]] || (( _antidote_missing )); then
        (( _antidote_missing )) && print -u2 'antidote: plugin files missing, re-cloning...'
        antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
    fi
    source ${zsh_plugins}.zsh
fi
unset _antidote_path _antidote_missing _antidote_line _antidote_file

# Replaces the oh-my-zsh flutter plugin. That plugin runs `flutter
# zsh-completion` in the background on EVERY shell start, and each `flutter`
# call takes the SDK startup lock, so opening several panes at once (the herdr
# dev layout opens five) produced "Waiting for another flutter command to
# release the startup lock". Regenerate the completion only when the SDK
# version file is newer than the cached completion.
if (( $+commands[flutter] )); then
    _flutter_comp="$ZSH_CACHE_DIR/completions/_flutter"
    _flutter_ver="$HOME/flutter/bin/cache/flutter.version.json"
    if [[ ! -f $_flutter_comp || $_flutter_ver -nt $_flutter_comp ]]; then
        mkdir -p "${_flutter_comp:h}"
        flutter zsh-completion < /dev/null >| "$_flutter_comp" &|
    fi
    # compinit has already run, so bind the completion by hand.
    if [[ -f $_flutter_comp ]]; then
        fpath+=("${_flutter_comp:h}")
        autoload -Uz _flutter
        compdef _flutter flutter
    fi
    unset _flutter_comp _flutter_ver

    alias fl="flutter"
    alias flattach="flutter attach"
    alias flb="flutter build"
    alias flchnl="flutter channel"
    alias flc="flutter clean"
    alias fldvcs="flutter devices"
    alias fldoc="flutter doctor"
    alias flpub="flutter pub"
    alias flget="flutter pub get"
    alias flr="flutter run"
    alias flrd="flutter run --debug"
    alias flrp="flutter run --profile"
    alias flrr="flutter run --release"
    alias flupgrd="flutter upgrade"
fi


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

# fzf shell integration — ctrl+r history, ctrl+t files, alt+c cd.
# fzf arrived only as a dependency of `navi` and was never wired up; bound
# deliberately 2026-08-19. Sourced AFTER the antidote plugins and after
# `bindkey -v` so it captures the right default completion widget and its
# viins/vicmd bindings are not clobbered. Tab is unchanged unless you type
# the `**` trigger.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi


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



# --- ensure nvm's default node is statically on PATH ---
# nvm's own activation doesn't survive Claude Code's shell-snapshot generation
# (node gets stripped on rc re-source), so npx-based MCP servers can't find `node`.
# A plain export at end-of-rc is captured in the snapshot. See Obsidian note:
# "MCP npx Shell Snapshot Bug".
if [ -r "$NVM_DIR/alias/default" ]; then
  __nvm_def="$(command cat "$NVM_DIR/alias/default")"
  __nvm_dir="$(command ls -d "$NVM_DIR"/versions/node/v"${__nvm_def#v}"* 2>/dev/null | sort -V | tail -1)"
  [ -n "$__nvm_dir" ] && [ -x "$__nvm_dir/bin/node" ] && export PATH="$__nvm_dir/bin:$PATH"
  unset __nvm_def __nvm_dir
fi

# Machine-only settings. Not tracked by dots.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
