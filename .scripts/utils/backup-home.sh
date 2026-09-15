#!/usr/bin/env bash
#
# backup-home.sh — mirror the useful parts of /Users/cunderw onto the external
# APFS drive at /Volumes/MacStorage/Backups/carson-mac, so a new Mac can be set
# up from it offline.
#
# Semantics: MIRROR. Sets A, C and D run with --delete, so a file removed from
# the Mac is removed from the backup on the next run. --delete is only ever
# pointed at a directory *inside* carson-mac. Set B (loose top-level dot files)
# runs without --delete, because its rsync source is a file list rather than a
# directory and --delete against a file list is a foot-gun.
#
# Layout on the destination mirrors $HOME:
#   carson-mac/.claude, carson-mac/.config, carson-mac/Dev/..., carson-mac/.zshrc
# Logs are written next to carson-mac, in /Volumes/MacStorage/Backups/_logs/,
# so they are never part of the restored home directory.
#
# Usage:
#   ./backup-home.sh          mirror everything
#   ./backup-home.sh -n       dry run: report what would transfer, change nothing
#   ./backup-home.sh -h       this text
#
# Flags:
#   -n, --dry-run   pass --dry-run to every rsync call
#   -h, --help      this text
#
# Requires Homebrew rsync 3.x at /opt/homebrew/bin/rsync. macOS /usr/bin/rsync
# is openrsync, where -E means xattrs and --info/--filter behave differently;
# this script refuses to fall back to it.
#
set -euo pipefail

HOME_DIR="/Users/cunderw"
VOL="/Volumes/MacStorage"
BACKUP_ROOT="$VOL/Backups"
DST="$BACKUP_ROOT/carson-mac"
LOG_DIR="$BACKUP_ROOT/_logs"
LOCK="$BACKUP_ROOT/.backup-home.lock"
RSYNC="/opt/homebrew/bin/rsync"

fail() { echo "ERROR: $*" >&2; exit 1; }

# ------------------------------------------------------------------- arguments
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -h|--help)    sed -n '3,29p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------- guards
# An unmounted volume turns the mount point into an empty local directory that
# rsync will happily fill, and --delete into a way to lose the previous backup.
[[ -d "$VOL" ]] || fail "$VOL not found — is the external drive connected?"
mount | grep -q " on $VOL " || fail "$VOL is not a mount point — is the external drive connected?"
[[ -d "$DST" ]] || fail "$DST does not exist. Create it yourself; this script will not."
[[ -x "$RSYNC" ]] || fail "$RSYNC not found. Install it with: brew install rsync"

case "$($RSYNC --version | head -1 | awk '{print $3}')" in
  3.*) : ;;
  *)   fail "$RSYNC is not rsync 3.x" ;;
esac

# Lock. A stale lock from a killed run is taken over once its PID is gone.
if ! mkdir "$LOCK" 2>/dev/null; then
  if [[ -f "$LOCK/pid" ]] && kill -0 "$(cat "$LOCK/pid")" 2>/dev/null; then
    fail "another backup-home.sh is running (pid $(cat "$LOCK/pid"))"
  fi
  echo "WARNING: taking over a stale lock at $LOCK" >&2
  rm -rf "$LOCK"
  mkdir "$LOCK" || fail "cannot create lock $LOCK"
fi
echo $$ >"$LOCK/pid"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/backup-home.XXXXXX")"
# shellcheck disable=SC2329  # invoked by the trap below, which shellcheck does not follow
cleanup() { rm -rf "$LOCK" "$TMP"; }
trap cleanup EXIT INT TERM

mkdir -p "$LOG_DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$LOG_DIR/backup-$STAMP.log"
[[ $DRY_RUN -eq 1 ]] && LOG="$LOG_DIR/dryrun-$STAMP.log"

log() { echo "$@" | tee -a "$LOG"; }

# ----------------------------------------------------------------- rsync flags
# -r recursive, -l symlinks stay symlinks, -p modes, -t mtimes, -D devices and
# specials, -X extended attributes.
# NOT -o/-g: the destination APFS volume is mounted noowners, so preserving
# uid/gid is both impossible and pointless.
# -N (crtimes) is deliberately left off: it is optional here and adds a class of
# per-file failures for no restore value.
BASE_FLAGS=(-rlptDX --human-readable --stats --info=progress2)
[[ $DRY_RUN -eq 1 ]] && BASE_FLAGS+=(--dry-run)

# Junk that should never be copied, wherever it appears.
JUNK=(.DS_Store '._*' .Spotlight-V100 .fseventsd .Trashes)

# Caches, toolchains and package stores. All of it is re-downloadable, and some
# of it is enormous. Never copied from anywhere.
NEVER=(
  .nvm .local .cache .rustup .pub-cache .npm .cargo .rbenv .bun .docker
  .gradle .gem .cocoapods .dart .dart-tool .dart_tool .dartServer .swiftpm
  .pnpm-store .pnpm-state .thumbnails .Trash .zsh_sessions .bundle .java
  .homebrew .flutter-devtools .bi-sockets
)

EXCLUDES=()
for p in "${JUNK[@]}" "${NEVER[@]}"; do EXCLUDES+=(--exclude="$p"); done

# Set B loses a handful of extra files that are either regenerable or noise.
SETB_EXCLUDES=(
  --exclude=.DS_Store
  --exclude=.bash_history
  --exclude=.viminfo
  --exclude=.wget-hsts
  --exclude=.zshrc.zwc
  --exclude=.zsh_plugins.zsh
  --exclude=.zshrc.bak-nvm-rename
  --exclude='.claude.json.tmp.*'
)

FAILED=0
SYNCED=0

# run_rsync <label> <rsync args...>
# rsync exit 24 means "source files vanished during transfer", which is normal
# on a live home directory and is not a failure.
run_rsync() {
  local label="$1"; shift
  local rc=0
  log "=== $label ==="
  set +e
  "$RSYNC" "$@" 2>&1 | tee -a "$LOG"
  rc=${PIPESTATUS[0]}
  set -e
  if [[ $rc -eq 0 || $rc -eq 24 ]]; then
    SYNCED=$((SYNCED + 1))
  else
    log "!! rsync exited $rc for $label"
    FAILED=$((FAILED + 1))
  fi
  echo | tee -a "$LOG"
}

log "backup-home  $(date)"
log "rsync:  $RSYNC ($($RSYNC --version | head -1 | awk '{print $3}'))"
log "mode:   $([[ $DRY_RUN -eq 1 ]] && echo 'DRY RUN — nothing is written' || echo 'LIVE — mirrors with --delete')"
log "source: $HOME_DIR"
log "dest:   $DST"
log "log:    $LOG"
log ""

# ============================================================== Set A + Set C
# Whole directories, mirrored. ~/.dotfiles is the bare dotfiles repo itself, so
# the new Mac can clone from the backup with no network.
SET_A=(
  .claude .codex .agents .config .ssh .gnupg .appstoreconnect
  Obsidian .scripts .bin .dotfiles
)

for name in "${SET_A[@]}"; do
  src="$HOME_DIR/$name"
  if [[ ! -e "$src" ]]; then
    log "SKIP  $name — not present in $HOME_DIR"
    continue
  fi
  # Trailing slashes: copy the CONTENTS of src into dst/name.
  run_rsync "$name" "${BASE_FLAGS[@]}" --delete "${EXCLUDES[@]}" "$src/" "$DST/$name/"
done

# ===================================================================== Set B
# Loose top-level dot files, plus anything the dotfiles repo tracks at the top
# level that sets A and B do not already cover (today: README.md).
SET_B=(
  .zshrc .zprofile .zshenv .profile .gitconfig .tmux.conf .vimrc
  .zsh_plugins.txt .mailcap .mime.types .flutter .claude.json
  .zsh_history .gitignore
)

# Anything `git ls-files` lists must land in the backup. Everything under
# .config/ and .scripts/ is already covered by set A; the rest is top-level.
DOTFILES_GIT=(git --git-dir="$HOME_DIR/.dotfiles" --work-tree="$HOME_DIR")
EXTRA=()
if [[ -d "$HOME_DIR/.dotfiles" ]]; then
  while IFS= read -r tracked; do
    [[ -n "$tracked" ]] || continue
    covered=0
    for name in "${SET_A[@]}"; do
      [[ "$tracked" == "$name/"* || "$tracked" == "$name" ]] && covered=1 && break
    done
    if [[ $covered -eq 0 ]]; then
      for name in "${SET_B[@]}"; do
        [[ "$tracked" == "$name" ]] && covered=1 && break
      done
    fi
    if [[ $covered -eq 0 ]]; then
      EXTRA+=("$tracked")
      log "NOTE  dotfiles-tracked path not covered by sets A/B, adding: $tracked"
    fi
  done < <("${DOTFILES_GIT[@]}" ls-files 2>/dev/null || true)
else
  log "SKIP  .dotfiles — bare repo not present, cannot check tracked paths"
fi

SETB_SRC=()
for name in "${SET_B[@]}" ${EXTRA[@]+"${EXTRA[@]}"}; do
  if [[ -e "$HOME_DIR/$name" ]]; then
    SETB_SRC+=("$HOME_DIR/$name")
  else
    log "SKIP  $name — not present in $HOME_DIR"
  fi
done

if [[ ${#SETB_SRC[@]} -gt 0 ]]; then
  # No --delete here on purpose: the sources are a file list, not a directory,
  # so --delete would target everything else already in carson-mac/.
  run_rsync "top-level files (${#SETB_SRC[@]})" \
    "${BASE_FLAGS[@]}" "${SETB_EXCLUDES[@]}" "${EXCLUDES[@]}" \
    "${SETB_SRC[@]}" "$DST/"
fi

# ===================================================================== Set D
# ~/Dev: git-tracked files plus each repo's .git directory, and nothing else.
#
# Why not `git ls-files` piped to --files-from: --files-from disables --delete's
# ability to mirror. Why not a per-directory `--filter=':- .gitignore'`: repos
# like personal/drover and personal/battle-buddies keep their ignores in
# .git/info/exclude, which a per-directory filter cannot see. Missing drover's
# alone would copy .claude/worktrees, 3.6G of build output.
DEV="$HOME_DIR/Dev"
MAX_TREE_KB=$((50 * 1024))   # non-git trees larger than this are skipped

if [[ ! -d "$DEV" ]]; then
  log "SKIP  Dev — $DEV not present"
else
  RECORDS="$TMP/dev-records"
  : >"$RECORDS"

  # Classify a directory:
  #   REPO  it holds a .git — back up tracked files plus .git, do not descend
  #   TREE  no .git anywhere below it — back up whole, subject to the size cap
  #   else  mixed: take its loose files and recurse into its subdirectories
  #
  # Descending top-down and stopping at the first .git is what keeps nested
  # SwiftPM checkouts (drover/DroverKit/.build/checkouts/*/.git) and agent
  # worktrees (drover/.claude/worktrees/*/.git) from being treated as repos of
  # their own. A flat `find -name .git` finds 96 of them under ~/Dev; only 28
  # are real project roots.
  classify() {
    local d="$1" child
    if [[ -e "$d/.git" ]]; then
      printf 'REPO\t%s\n' "$d" >>"$RECORDS"
      return
    fi
    if ! find "$d" -name .git -print -quit 2>/dev/null | grep -q .; then
      printf 'TREE\t%s\n' "$d" >>"$RECORDS"
      return
    fi
    while IFS= read -r -d '' child; do
      printf 'FILE\t%s\n' "$child" >>"$RECORDS"
    done < <(find "$d" -mindepth 1 -maxdepth 1 \! -type d -print0 2>/dev/null)
    while IFS= read -r -d '' child; do
      classify "$child"
    done < <(find "$d" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  }
  classify "$DEV"

  # rsync filter patterns treat * ? [ and \ as metacharacters.
  esc() { printf '%s' "$1" | sed 's/[][*?\\]/\\&/g'; }

  INCL="$TMP/dev-includes"
  : >"$INCL"

  # Emit `+ /a/`, `+ /a/b/` ... for every parent directory of a relative path,
  # because rsync will not descend into a directory it has not been told to
  # include.
  ancestors() {
    local p="$1" cur="" i=0 n
    local oldifs="$IFS"
    local segs
    IFS='/' read -r -a segs <<<"$p"
    IFS="$oldifs"
    n=${#segs[@]}
    while [[ $i -lt $((n - 1)) ]]; do
      cur="$cur/$(esc "${segs[$i]}")"
      printf '+ %s/\n' "$cur" >>"$INCL"
      i=$((i + 1))
    done
  }

  BAD_NAMES=0
  REPO_COUNT=0
  TRACKED_COUNT=0

  while IFS=$'\t' read -r kind path; do
    rel="${path#"$DEV"/}"
    case "$kind" in
      REPO)
        REPO_COUNT=$((REPO_COUNT + 1))
        ancestors "$rel/x"
        printf '+ /%s/\n' "$(esc "$rel")" >>"$INCL"
        printf '+ /%s/.git/***\n' "$(esc "$rel")" >>"$INCL"
        while IFS= read -r -d '' f; do
          case "$f" in
            *$'\n'*) log "WARNING  skipping tracked path with a newline in $rel"; BAD_NAMES=$((BAD_NAMES + 1)); continue ;;
          esac
          TRACKED_COUNT=$((TRACKED_COUNT + 1))
          ancestors "$rel/$f"
          printf '+ /%s/%s\n' "$(esc "$rel")" "$(esc "$f")" >>"$INCL"
        done < <(git -C "$path" ls-files -z 2>/dev/null || true)
        ;;
      TREE)
        kb="$(du -sk "$path" 2>/dev/null | awk '{print $1}')"
        kb="${kb:-0}"
        if [[ $kb -gt $MAX_TREE_KB ]]; then
          log "SKIP  Dev/$rel — non-git tree is $((kb / 1024))M, over the ${MAX_TREE_KB}K cap"
          continue
        fi
        ancestors "$rel/x"
        printf '+ /%s/***\n' "$(esc "$rel")" >>"$INCL"
        ;;
      FILE)
        ancestors "$rel"
        printf '+ /%s\n' "$(esc "$rel")" >>"$INCL"
        ;;
    esac
  done <"$RECORDS"

  # One gitignored file is wanted anyway: the local env for unraid-tower.
  # tides_of_sorrow's android/local.properties is deliberately NOT included.
  EXTRA_DEV=("personal/unraid-tower/.env.local")
  for rel in "${EXTRA_DEV[@]}"; do
    if [[ -e "$DEV/$rel" ]]; then
      ancestors "$rel"
      printf '+ /%s\n' "$(esc "$rel")" >>"$INCL"
    else
      log "SKIP  Dev/$rel — not present"
    fi
  done

  FILTER="$TMP/dev-filter"
  {
    for p in "${JUNK[@]}"; do printf -- '- %s\n' "$p"; done
    sort -u "$INCL"
    for p in "${NEVER[@]}"; do printf -- '- %s\n' "$p"; done
    printf -- '- *\n'
  } >"$FILTER"

  INCL_N="$(grep -c '^+ ' "$FILTER" || true)"
  log "Dev: $REPO_COUNT repos, $TRACKED_COUNT tracked files, $INCL_N filter include rules"
  [[ $BAD_NAMES -eq 0 ]] || log "Dev: $BAD_NAMES paths skipped for unrepresentable names"
  cp "$FILTER" "$LOG_DIR/dev-filter-$STAMP.txt"
  log "Dev filter saved to $LOG_DIR/dev-filter-$STAMP.txt"

  # --delete-excluded is required, not cosmetic. With a whitelist filter ending
  # in `- *`, every file the filter does not name counts as excluded, and rsync
  # protects excluded files on the receiver from --delete. Without this flag a
  # file deleted from a repo would live in the backup forever. Because it makes
  # --delete far broader, refuse to run on a filter that looks truncated.
  if [[ ${INCL_N:-0} -lt 50 ]]; then
    log "!! Dev filter has only $INCL_N include rules — refusing to run --delete-excluded against $DST/Dev"
    FAILED=$((FAILED + 1))
  else
    run_rsync "Dev (tracked files only)" \
      "${BASE_FLAGS[@]}" --delete --delete-excluded \
      --filter="merge $FILTER" \
      "$DEV/" "$DST/Dev/"
  fi
fi

# ===================================================================== wrap up
log "----------------------------------------"
[[ $DRY_RUN -eq 1 ]] && log "DRY RUN complete — nothing was written."
log "rsync runs OK: $SYNCED   failed: $FAILED"
log "log: $LOG"
exit $(( FAILED > 0 ? 1 : 0 ))
