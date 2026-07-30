#!/usr/bin/env bash
#
# Run a command in the focused pane's working directory.
# Equivalent of tmux's `display-popup -d "#{pane_current_path}"`, which herdr
# popups have no documented option for.
#
#   usage: in-pane-cwd.sh <command> [args...]

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

dir=$("$herdr" pane list 2>/dev/null \
  | jq -r 'first(.result.panes[] | select(.focused) | .foreground_cwd // .cwd) // empty' 2>/dev/null || true)

if [ -n "${dir:-}" ] && [ -d "$dir" ]; then
  cd "$dir"
fi

exec "$@"
