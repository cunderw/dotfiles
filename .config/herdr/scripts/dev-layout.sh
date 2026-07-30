#!/usr/bin/env bash
#
# Port of the tmux `bind D` dev layout:
#   3/4 nvim (left) | claude (top-right) | terminal (bottom-right)
#
# Difference from the tmux version: claude is started via `herdr agent start`
# rather than send-keys, so herdr tracks it as a real agent and the sidebar
# shows its working/blocked/idle state.

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

# The pane we were invoked from becomes the nvim pane.
focused=$("$herdr" pane list | jq -r 'first(.result.panes[] | select(.focused)) | "\(.pane_id)\t\(.foreground_cwd // .cwd)"')
base=${focused%%$'\t'*}
cwd=${focused#*$'\t'}
if [ -z "$base" ]; then
  echo "dev-layout: no focused pane" >&2
  exit 1
fi

# tmux used -c "#{pane_current_path}" on both splits.
# Right column at 25% -> claude
right=$("$herdr" pane split "$base" --direction right --ratio 0.25 --cwd "$cwd" | jq -r '.result.pane.pane_id')

# Split the right column -> plain terminal bottom-right
"$herdr" pane split "$right" --direction down --cwd "$cwd" >/dev/null

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
