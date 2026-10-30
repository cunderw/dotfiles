#!/usr/bin/env bash
#
# Dev layout for the Herdr app, run by mods/dev-layout (ctrl-b shift-d).
#
#   tab "dev"                     tab "git" -> lazygit
#   +-----------+-----------+
#   |   nvim    |  claude   |
#   +-----------+-----------+
#   |   app     |  shell    |
#   +-----------+-----------+
#
# Columns 44/56, rows 75/25, as weights: pane.split has no ratio.
#
#   usage: dev-layout.sh <pane> <terminal> <tab> <space> <cwd>

set -euo pipefail

base=$1 terminal=$2 tab=$3 space=$4 cwd=$5

split() {
  herdr-app do pane.split "$(jq -nc --arg p "$1" --arg d "$2" '{direction:$d,pane:$p}')"
}

resize() {
  herdr-app do layout.resize "$(jq -nc --arg p "$1" --argjson w "$2" '{id:$p,weight:$w}')" >/dev/null
}

# claude starts last: a pane still launching it gives its split the home folder.
right=$(split "$base" right)
right_pane=$(jq -r .pane <<<"$right")

# Widths first: a pane's size moves to the column that wraps it on the next
# split, and the column's id is not returned, so it can't be sized afterwards.
resize "$base" 0.44
resize "$right_pane" 0.56

app=$(split "$base" down)
shell=$(split "$right_pane" down)

resize "$base" 0.75
resize "$(jq -r .pane <<<"$app")" 0.25
resize "$right_pane" 0.75
resize "$(jq -r .pane <<<"$shell")" 0.25

herdr-app do tab.rename --id "$tab" --name dev >/dev/null
herdr-app do tab.new --name git --space "$space" --folder "$cwd" --argv '["lazygit"]' >/dev/null
herdr-app do tab.select --id "$tab" >/dev/null

# A split of a pane this new starts in the space's folder, not the pane's.
hc send "$(jq -r .terminal <<<"$shell")" "cd $(printf %q "$cwd") && clear" >/dev/null
hc send "$terminal" nvim >/dev/null
hc send "$(jq -r .terminal <<<"$right")" claude >/dev/null
herdr-app do pane.focus --pane "$base" >/dev/null
