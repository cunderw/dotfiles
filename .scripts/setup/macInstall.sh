#!/bin/bash
# Bootstrap a new Mac.
#
# Run order:
#   1. macInstall.sh   - Homebrew, then every package from ./Brewfile
#   2. macSetup.sh     - macOS defaults
#   3. herdrSetup.sh   - herdr plugins (machine-local, not brew-installable)
#
# Packages are NOT listed here any more. They live in ./Brewfile, which is
# generated from the machine so it cannot drift out of date the way a
# hand-maintained `brew install` list did. Regenerate after installing
# anything you want to keep:
#
#   brew bundle dump --force --file="$HOME/.scripts/setup/Brewfile"
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

# --- Homebrew ---------------------------------------------------------------

if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_PREFIX=/opt/homebrew
[ -x "$BREW_PREFIX/bin/brew" ] || BREW_PREFIX=/usr/local  # Intel fallback

# Put brew on PATH for login shells, once. Appending unconditionally is how
# the old version of this script ended up with duplicate lines.
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >>"$HOME/.zprofile"
fi
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# --- Packages ---------------------------------------------------------------

# `brew bundle` is built into Homebrew 4+; the homebrew/bundle tap is obsolete.
# Casks, taps and fonts all come from the Brewfile too - fonts moved into
# homebrew/cask in 2024, so no font tap is needed either.

if [ ! -f "$BREWFILE" ]; then
    echo "No Brewfile at $BREWFILE" >&2
    exit 1
fi

echo "Installing packages from $BREWFILE ..."
brew bundle install --file="$BREWFILE"

# --- Next steps -------------------------------------------------------------

cat <<'EOF'

Homebrew packages installed. Remaining steps:

  ~/.scripts/setup/macSetup.sh     # macOS defaults (Finder, Dock, Safari...)
  ~/.scripts/setup/herdrSetup.sh   # herdr plugins - see that script's notes

EOF
