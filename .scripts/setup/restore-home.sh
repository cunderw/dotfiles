#!/usr/bin/env bash
#
# restore-home.sh — bring a fresh Mac up from /Volumes/MacStorage/Backups/carson-mac
# (written by ~/.scripts/utils/backup-home.sh) plus the setup scripts next to
# this file.
#
# Before running, on the NEW Mac:
#   1. Sign in to iCloud (Keychain, Photos, Drive) in System Settings.
#   2. Sign in to the App Store app (mas cannot do it for you).
#   3. Plug in MacStorage.
#   4. Open Terminal and run:  /Volumes/MacStorage/Backups/carson-mac/.scripts/setup/restore-home.sh
#
# Steps run in order and each is idempotent. Re-run with --from N to resume
# after a failure. --dry-run prints every step and runs nothing.
#
set -euo pipefail

VOL="/Volumes/MacStorage"
SRC="$VOL/Backups/carson-mac"
EXTRAS="$SRC/_extras"
RSYNC="${RSYNC:-/usr/bin/rsync}"   # openrsync is fine for a one-way copy
UID_NUM="$(id -u)"

FROM=1
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="${2:?--from needs a number}"; shift 2 ;;
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

fail() { echo "ERROR: $*" >&2; exit 1; }
say()  { printf '\n\033[1m== %s ==\033[0m\n' "$*"; }
run()  { printf '  \033[2m$ %s\033[0m\n' "$*"; [[ $DRY_RUN -eq 1 ]] || "$@"; }

STEP=0
step() {  # step <title>; returns 1 (skip) when below --from
  STEP=$((STEP + 1))
  if [[ $STEP -lt $FROM ]]; then return 1; fi
  say "$STEP. $1"
  return 0
}

# ---------------------------------------------------------------------- guards
[[ "$(uname -m)" == "arm64" ]] || fail "this script assumes Apple Silicon (/opt/homebrew)"
mount | grep -q " on $VOL " || fail "$VOL is not mounted"
[[ -d "$SRC/.dotfiles" ]] || fail "$SRC does not look like a backup-home.sh mirror"
[[ "$HOME" == "/Users/cunderw" ]] || fail "backup paths assume /Users/cunderw, HOME is $HOME"

# =============================================================================
if step "Xcode Command Line Tools (git, python3, rsync)"; then
  if ! xcode-select -p >/dev/null 2>&1; then
    run xcode-select --install
    echo "  Finish the installer dialog, then re-run:  $0 --from $STEP"
    [[ $DRY_RUN -eq 1 ]] || exit 0
  fi
fi

# =============================================================================
if step "Copy the home mirror into \$HOME (dot dirs, dotfiles, Obsidian, Dev)"; then
  # -a keeps modes (.ssh 700/600). No --delete: never remove anything on the new
  # Mac. _extras is restored piecewise later, not copied to ~/_extras.
  run "$RSYNC" -a --info=progress2 \
    --exclude='/_extras' --exclude='.DS_Store' --exclude='._*' \
    "$SRC/" "$HOME/"
  run chmod 700 "$HOME/.ssh" "$HOME/.gnupg" 2>/dev/null || true
  run chmod 600 "$HOME/.ssh/id_rsa" "$HOME/.ssh/config" 2>/dev/null || true
  # The bare dotfiles repo came back; tell it where its work tree is and hide
  # the thousands of untracked files a home dir has.
  run git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config core.bare false
  run git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config core.worktree "$HOME"
  run git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" config status.showUntrackedFiles no
fi

# =============================================================================
if step "Homebrew and the Brewfile (macInstall.sh)"; then
  run "$HOME/.scripts/setup/macInstall.sh" || echo "  brew bundle reported failures; npm and cargo lines are retried in the next steps"
fi

# =============================================================================
if step "Node via nvm (not brew; .zshrc sources ~/.nvm/nvm.sh)"; then
  NODE_DEFAULT="$(cat "$EXTRAS/lists/node-default.txt" 2>/dev/null || echo lts/*)"
  if [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
    run bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | PROFILE=/dev/null bash'
  fi
  run bash -c ". \"$HOME/.nvm/nvm.sh\" && nvm install \"$NODE_DEFAULT\" && nvm alias default \"$NODE_DEFAULT\""
  echo "  other versions that were installed (install by hand if a project needs one):"
  cat "$EXTRAS/lists/node-versions.txt" 2>/dev/null | sed 's/^/    /' || true
fi

# =============================================================================
if step "Rust toolchain (brew rustup installs no toolchain by itself)"; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  run rustup default stable
fi

# =============================================================================
if step "Second brew bundle pass for the npm and cargo lines"; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  run bash -c ". \"$HOME/.nvm/nvm.sh\" && brew bundle install --file=\"$HOME/.scripts/setup/Brewfile\""
fi

# =============================================================================
if step "CLI tools that live in ~/.local/bin (not backed up)"; then
  run mkdir -p "$HOME/.local/bin"
  if ! command -v claude >/dev/null 2>&1; then
    run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  fi
  run bash -c ". \"$HOME/.nvm/nvm.sh\" && npm install -g @openai/codex"
  run "$RSYNC" -a "$EXTRAS/.local/bin/set-ha-token-env.sh" "$HOME/.local/bin/"
fi

# =============================================================================
if step "herdr plugins (herdrSetup.sh); drop the old plugins.json with absolute paths first"; then
  run rm -f "$HOME/.config/herdr/plugins.json"
  run "$HOME/.scripts/setup/herdrSetup.sh"
fi

# =============================================================================
if step "tmux plugins via tpm"; then
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  run "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

# =============================================================================
if step "Neovim plugins (lazy.nvim restores from lazy-lock.json)"; then
  run nvim --headless "+Lazy! restore" +qa
fi

# =============================================================================
if step "macOS defaults: imported domains, then macSetup.sh"; then
  for f in "$EXTRAS"/defaults/*.plist; do
    [[ -e "$f" ]] || continue
    d="$(basename "$f" .plist)"
    if [[ "$d" == "NSGlobalDomain" ]]; then
      run defaults import -g "$f"
    else
      run defaults import "$d" "$f"
    fi
  done
  run "$HOME/.scripts/setup/macSetup.sh"
  if [[ -s "$EXTRAS/lists/computer-name.txt" ]]; then
    NAME="$(cat "$EXTRAS/lists/computer-name.txt")"
    run sudo scutil --set ComputerName "$NAME"
    run sudo scutil --set LocalHostName "$(echo "$NAME" | tr -cd '[:alnum:]-')"
    run sudo scutil --set HostName "$(echo "$NAME" | tr -cd '[:alnum:]-')"
  fi
fi

# =============================================================================
if step "App state under ~/Library (Claude desktop, Moonlight, Xcode, spelling, Obsidian vault list)"; then
  for rel in \
    "Library/Application Support/Claude/claude_desktop_config.json" \
    "Library/Application Support/Claude/Claude Extensions" \
    "Library/Application Support/Claude/Claude Extensions Settings" \
    "Library/Application Support/obsidian/obsidian.json" \
    "Library/Preferences/com.moonlight-stream.Moonlight.plist" \
    "Library/Developer/Xcode/UserData/KeyBindings" \
    "Library/Developer/Xcode/UserData/FontAndColorThemes" \
    "Library/Developer/Xcode/UserData/CodeSnippets" \
    "Library/Developer/Xcode/UserData/IDETemplateMacros.plist" \
    "Library/MobileDevice/Provisioning Profiles" \
    "Library/Spelling" \
    ".driverr"; do
    [[ -e "$EXTRAS/$rel" ]] || continue
    run mkdir -p "$(dirname "$HOME/$rel")"
    run "$RSYNC" -a "$EXTRAS/$rel" "$(dirname "$HOME/$rel")/"
  done
fi

# =============================================================================
if step "Vault automation: daily digest and dream launch agents, HA token env agent"; then
  run "$HOME/Obsidian/PersonalVault/.system/install-digest.sh"
  run mkdir -p "$HOME/Library/LaunchAgents"
  P="$EXTRAS/Library/LaunchAgents/com.cunderw.set-ha-token-env.plist"
  if [[ -e "$P" ]]; then
    run cp "$P" "$HOME/Library/LaunchAgents/"
    run launchctl bootout "gui/$UID_NUM/com.cunderw.set-ha-token-env" 2>/dev/null || true
    run launchctl bootstrap "gui/$UID_NUM" "$HOME/Library/LaunchAgents/com.cunderw.set-ha-token-env.plist"
  fi
  # Tmux.Start.plist is written by tmux-continuum itself once tmux runs with
  # @continuum-boot on; nothing to copy.
  run git -C "$HOME/Obsidian/PersonalVault" remote -v
fi

# =============================================================================
if step "Sanity checks"; then
  run git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status --short
  run bash -lc 'command -v brew starship antidote fzf nvim tmux herdr claude codex gh; gh auth status'
  run launchctl list | grep -E 'com.cunderw|Tmux' || true
  echo
  echo "Simulators that existed before (create in Xcode > Devices if needed):"
  cat "$EXTRAS/lists/simulators.txt" 2>/dev/null | grep -E 'Driverr|BB' | sed 's/^/  /' || true
  echo
  echo "Dock apps before (macSetup.sh + the imported com.apple.dock plist should match):"
  grep file-label "$EXTRAS/lists/dock-apps.txt" 2>/dev/null | sed 's/^/  /' || true
fi

cat <<'EOF'

Left to do by hand:
  - Xcode: Settings > Accounts > sign in, then import the signing certificates
    you exported from the old Mac (Keychain Access > My Certificates > export .p12).
    iCloud Keychain does NOT carry developer certificate private keys.
  - Raycast: sign in; settings come back through cloud sync.
  - Google Chrome and Firefox: sign in for sync.
  - Discord, Home Assistant app, Moonlight (re-pair if the plist did not carry the hosts).
  - System Settings > Privacy & Security: grant Accessibility / Screen Recording to
    Raycast, Mac Mouse Fix, Ghostty, Claude as they ask.
  - Login items: Raycast, Mac Mouse Fix (add in System Settings > General > Login Items).
  - Log out and back in so the imported defaults (scroll direction, key repeat) apply.
EOF
