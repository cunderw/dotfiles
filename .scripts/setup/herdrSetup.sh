#!/bin/bash
# Install the herdr plugins referenced by ~/.config/herdr/config.toml.
#
# Run AFTER macInstall.sh (which brew-installs herdr itself) and after the dots
# repo has placed ~/.config/herdr/config.toml.
#
# These are NOT tracked in the dots repo: `herdr plugin install` writes a
# machine-local checkout under ~/.config/herdr/plugins/ plus a plugins.json
# registry with absolute paths, neither of which is portable between machines.
# The config.toml keybindings ARE tracked, so without this step those binds
# reference plugin actions that do not resolve.
set -euo pipefail

if ! command -v herdr >/dev/null 2>&1; then
  echo "herdr not on PATH — run macInstall.sh first" >&2
  exit 1
fi

# --yes is required when stdin is not a TTY (herdr gates remote installs).
#
# termscope — open files/URLs visible in the focused pane via a picker.
#   Bound to prefix+ctrl+o. Its build step brew-installs Television if missing.
herdr plugin install iurysza/termscope --yes

# herdr-splits.nvim — seamless ctrl+hjkl navigation and alt+shift+hjkl resizing
#   between Neovim splits and herdr panes. The Neovim half is a lazy.nvim spec
#   at .config/nvim/lua/plugins/herdr-splits.lua and installs itself.
herdr plugin install lmilojevicc/herdr-splits.nvim --yes

echo
echo "Installed plugins:"
herdr plugin list

cat <<'EOF'

Remaining manual step:
  alt+shift+h/j/k/l resizing needs the terminal to send Option as Meta.
  iTerm2: Profiles -> Keys -> Left Option key -> Esc+
  (Navigation on ctrl+hjkl works without this.)
EOF
