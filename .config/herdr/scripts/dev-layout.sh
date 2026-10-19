#!/usr/bin/env bash
#
# Dev layout, bound to prefix+shift+D.
#
#   tab "dev"
#   +--------------------+-------------------------+
#   |                    |                         |
#   |   nvim (75% tall)  |    claude (75% tall)    |
#   |                    |                         |
#   +--------------------+-------------------------+
#   |   app  (25% tall)  |    shell  (25% tall)    |
#   +--------------------+-------------------------+
#        44% wide                 56% wide
#
#   tab "git"  -> lazygit, full size, same cwd
#
#   Panes are labeled "<project>-<role>" (atc-connect-flutter-nvim, ...).
#
# claude starts via `herdr agent start` rather than send-keys, so herdr tracks
# it as a real agent and the sidebar shows its working/blocked/idle state.
# "app" is a plain shell for `flutter run` and similar; "shell" is a spare.
#
# NOTE ON --ratio: it is the fraction the *original* pane keeps, not the size
# of the new pane. `--ratio 0.75` leaves the base pane at 75% and gives the new
# pane 25%. Getting this backwards is what made nvim the narrow column.

set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

# The pane we were invoked from becomes the nvim pane.
focused=$("$herdr" pane list | jq -r 'first(.result.panes[] | select(.focused)) | "\(.pane_id)\t\(.tab_id)\t\(.workspace_id)\t\(.foreground_cwd // .cwd)"')
base=$(printf '%s' "$focused" | cut -f1)
tab=$(printf '%s' "$focused" | cut -f2)
workspace=$(printf '%s' "$focused" | cut -f3)
cwd=$(printf '%s' "$focused" | cut -f4)
if [ -z "$base" ]; then
  echo "dev-layout: no focused pane" >&2
  exit 1
fi

# Right column: nvim's column keeps 44% of the width, claude gets 56%.
right=$("$herdr" pane split "$base" --direction right --ratio 0.44 --cwd "$cwd" | jq -r '.result.pane.pane_id')

# Bottom 25% of each column: "app" under nvim, "shell" under claude.
app=$("$herdr" pane split "$base" --direction down --ratio 0.75 --cwd "$cwd" | jq -r '.result.pane.pane_id')
shell=$("$herdr" pane split "$right" --direction down --ratio 0.75 --cwd "$cwd" | jq -r '.result.pane.pane_id')

# Pane labels are "<project>-<role>", e.g. atc-connect-flutter-claude. The
# project is the main repo's directory name, so a git worktree such as
# ~/.herdr/worktrees/atc-connect-flutter/sc-123-foo still names the repo.
# Outside git, fall back to the last part of the cwd.
if common_dir=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  project=$(basename "$(dirname "$common_dir")")
else
  project=$(basename "$cwd")
fi

"$herdr" tab rename "$tab" dev >/dev/null
"$herdr" pane rename "$base" "$project-nvim" >/dev/null
"$herdr" pane rename "$app" "$project-app" >/dev/null
"$herdr" pane rename "$right" "$project-claude" >/dev/null
"$herdr" pane rename "$shell" "$project-shell" >/dev/null

# Second tab with lazygit, created without stealing focus from "dev".
git_pane=$("$herdr" tab create --workspace "$workspace" --cwd "$cwd" --label git | jq -r '.result.root_pane.pane_id')
"$herdr" pane rename "$git_pane" "$project-git" >/dev/null

# Agent names must be unique among live agents, so a bare "claude" fails once
# another dev layout is open. Key the name on the workspace id instead.
agent_name="claude-$(printf '%s' "$workspace" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9_-' '-')"

# A freshly split pane needs ~1-2s before its shell accepts an agent; herdr
# rejects it with agent_pane_busy until then. Poll instead of guessing.
started=false
for _ in $(seq 1 40); do
  if "$herdr" agent start "$agent_name" --kind claude --pane "$right" 2>/dev/null \
     | grep -q agent_started; then
    started=true
    break
  fi
  sleep 0.25
done
if [ "$started" != true ]; then
  echo "dev-layout: claude did not start in $right" >&2
fi

"$herdr" pane run "$git_pane" lazygit >/dev/null

# nvim in the top-left pane, then focus it (focus is directional only)
"$herdr" pane run "$base" nvim >/dev/null
"$herdr" pane focus --direction left --pane "$right" >/dev/null
