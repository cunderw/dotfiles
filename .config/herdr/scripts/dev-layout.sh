#!/usr/bin/env bash
#
# Port of the tmux `bind D` dev layout, bound to prefix+shift+D.
#
#   +---------------------------+----------------+
#   |                           |  claude  (75%) |
#   |      nvim  (75% wide)     +----------------+
#   |                           |  shell   (25%) |
#   +---------------------------+----------------+
#
# Differences from the tmux version: claude starts via `herdr agent start`
# rather than send-keys, so herdr tracks it as a real agent and the sidebar
# shows its working/blocked/idle state; and the tab and panes get labels.
#
# NOTE ON --ratio: it is the fraction the *original* pane keeps, not the size
# of the new pane. `--ratio 0.75` leaves the base pane at 75% and gives the new
# pane 25%. Getting this backwards is what made nvim the narrow column.

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

# The pane we were invoked from becomes the nvim pane.
focused=$("$herdr" pane list | jq -r 'first(.result.panes[] | select(.focused)) | "\(.pane_id)\t\(.tab_id)\t\(.foreground_cwd // .cwd)"')
base=$(printf '%s' "$focused" | cut -f1)
tab=$(printf '%s' "$focused" | cut -f2)
cwd=$(printf '%s' "$focused" | cut -f3)
if [ -z "$base" ]; then
  echo "dev-layout: no focused pane" >&2
  exit 1
fi

# tmux used -c "#{pane_current_path}" on both splits.
# Right column at 25% -> claude on top.
right=$("$herdr" pane split "$base" --direction right --ratio 0.75 --cwd "$cwd" | jq -r '.result.pane.pane_id')

# Split the right column: claude keeps 75%, shell gets the bottom 25%.
shell=$("$herdr" pane split "$right" --direction down --ratio 0.75 --cwd "$cwd" | jq -r '.result.pane.pane_id')

"$herdr" tab rename "$tab" dev >/dev/null
"$herdr" pane rename "$base" nvim >/dev/null
"$herdr" pane rename "$shell" shell >/dev/null

# A freshly split pane needs ~1-2s before its shell accepts an agent; herdr
# rejects it with agent_pane_busy until then. Poll instead of guessing.
for _ in $(seq 1 40); do
  if "$herdr" agent start claude --kind claude --pane "$right" 2>/dev/null \
     | grep -q agent_started; then
    break
  fi
  sleep 0.25
done

# nvim in the big left pane, then focus it (focus is directional only)
"$herdr" pane run "$base" nvim >/dev/null
"$herdr" pane focus --direction left --pane "$right" >/dev/null
