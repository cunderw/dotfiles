#!/usr/bin/env python3
"""Grouped, always-accurate herdr keybinding cheatsheet.

herdr's built-in prefix+? lists bindings flat. This renders the *effective* set
-- herdr's defaults merged with ~/.config/herdr/config.toml overrides -- grouped
by what the binding acts on, so it is scannable rather than alphabetical.

There is no API to query effective bindings (checked: the only `keys` in the
socket schema are send-keys params), so the defaults come from
`herdr --default-config`, whose lines ship commented out and need un-commenting
before they parse.

Usage:
  keys-help.py           render grouped sheet
  keys-help.py --plain   no ANSI colour (for piping)
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
import tomllib

CONFIG = os.path.expanduser("~/.config/herdr/config.toml")

# (group, action, label). Order here is the order rendered.
CATALOG: list[tuple[str, str, str]] = [
    ("Panes", "split_vertical", "split side-by-side"),
    ("Panes", "split_horizontal", "split stacked"),
    ("Panes", "close_pane", "close pane"),
    ("Panes", "zoom", "zoom / unzoom"),
    ("Panes", "rename_pane", "rename pane"),
    ("Panes", "resize_mode", "resize mode (then hjkl, Esc to exit)"),
    ("Panes", "focus_pane_left", "focus left"),
    ("Panes", "focus_pane_down", "focus down"),
    ("Panes", "focus_pane_up", "focus up"),
    ("Panes", "focus_pane_right", "focus right"),
    ("Panes", "cycle_pane_next", "cycle next"),
    ("Panes", "cycle_pane_previous", "cycle previous"),
    ("Panes", "last_pane", "last pane"),
    ("Panes", "edit_scrollback", "open scrollback in editor"),
    ("Tabs", "new_tab", "new tab"),
    ("Tabs", "rename_tab", "rename tab"),
    ("Tabs", "next_tab", "next tab"),
    ("Tabs", "previous_tab", "previous tab"),
    ("Tabs", "switch_tab", "jump to tab 1-9"),
    ("Tabs", "close_tab", "close tab"),
    ("Spaces", "new_workspace", "new space"),
    ("Spaces", "rename_workspace", "rename space"),
    ("Spaces", "next_workspace", "next space"),
    ("Spaces", "previous_workspace", "previous space"),
    ("Spaces", "switch_workspace", "jump to space 1-9"),
    ("Spaces", "close_workspace", "close space"),
    ("Spaces", "workspace_picker", "space picker (then j/k)"),
    ("Spaces", "goto", "session navigator"),
    ("Agents", "next_agent", "next agent"),
    ("Agents", "previous_agent", "previous agent"),
    ("Agents", "focus_agent", "focus agent 1-9"),
    ("Agents", "open_notification_target", "jump to notification"),
    ("Worktrees", "new_worktree", "new git worktree"),
    ("Worktrees", "open_worktree", "open worktree"),
    ("Worktrees", "remove_worktree", "remove worktree"),
    ("Session", "detach", "detach"),
    ("Session", "copy_mode", "copy mode (vi keys, / ? n N, v y)"),
    ("Session", "toggle_sidebar", "toggle sidebar"),
    ("Session", "reload_config", "reload config"),
    ("Session", "settings", "settings"),
    ("Session", "help", "built-in binding list"),
]

NAVIGATE = [
    ("navigate_workspace_up", "previous space"),
    ("navigate_workspace_down", "next space"),
    ("navigate_pane_left", "focus pane left"),
    ("navigate_pane_down", "focus pane down"),
    ("navigate_pane_up", "focus pane up"),
    ("navigate_pane_right", "focus pane right"),
]


def parse_defaults() -> dict[str, object]:
    """herdr --default-config ships commented out; un-comment to parse it.

    Parse each candidate line in isolation rather than reassembling a document:
    the default config contains prose comments that look like assignments
    ('# type = "shell" runs detached in the background.'), and one of those in a
    reassembled document makes the whole parse throw.
    """
    try:
        raw = subprocess.run(
            ["herdr", "--default-config"], capture_output=True, text=True, check=True
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return {}

    out: dict[str, object] = {}
    section = ""
    for line in raw.splitlines():
        header = re.match(r"^#?\s*\[+([a-z_.]+)\]+\s*$", line)
        if header:
            section = header.group(1)
            continue
        if section != "keys":
            continue
        m = re.match(r"^#\s*([a-z_]+)\s*=\s*(.+)$", line)
        if not m:
            continue
        value = re.sub(r"\s+#.*$", "", m.group(2)).strip()
        try:
            parsed = tomllib.loads(f"{m.group(1)} = {value}")
        except tomllib.TOMLDecodeError:
            continue  # prose that merely looks like an assignment
        out.update(parsed)
    return out


def load_user() -> tuple[dict[str, object], list[dict]]:
    try:
        with open(CONFIG, "rb") as fh:
            data = tomllib.load(fh)
    except (OSError, tomllib.TOMLDecodeError):
        return {}, []
    keys = data.get("keys", {})
    commands = keys.pop("command", []) if isinstance(keys, dict) else []
    return keys, commands


def chords(value) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value] if value.strip() else []
    if isinstance(value, list):
        return [v for v in value if isinstance(v, str) and v.strip()]
    return []


def report_conflicts(effective: dict, commands: list[dict]) -> int:
    """Find chords claimed by more than one action.

    This has to run against the MERGED set. A config-only scan cannot see the
    real failure mode: deleting an action from config.toml does not unbind it,
    it restores herdr's default, which then silently collides with something
    else. herdr itself emits no diagnostic for duplicate bindings.
    """
    owners: dict[str, list[str]] = {}
    for action, value in effective.items():
        if action == "prefix" or action.startswith("navigate_"):
            continue
        for chord in chords(value):
            owners.setdefault(chord, []).append(action)
    for cmd in commands:
        if isinstance(cmd, dict) and cmd.get("key"):
            label = cmd.get("description") or cmd.get("command", "command")
            owners.setdefault(cmd["key"], []).append(f"command: {label}")

    clashes = {k: v for k, v in owners.items() if len(v) > 1}
    if not clashes:
        print(f"no conflicts ({len(owners)} chords bound)")
        return 0
    print(f"{len(clashes)} conflict(s):")
    for chord, actions in sorted(clashes.items()):
        print(f"  {chord:24} {', '.join(actions)}")
    return 1


def main() -> int:
    plain = "--plain" in sys.argv or not sys.stdout.isatty()
    defaults = parse_defaults()
    user, commands = load_user()

    if "--conflicts" in sys.argv:
        return report_conflicts({**defaults, **user}, commands)

    def C(code: str, text: str) -> str:
        return text if plain else f"\033[{code}m{text}\033[0m"

    effective = {**defaults, **{k: v for k, v in user.items() if not isinstance(v, list) or True}}
    prefix = chords(effective.get("prefix")) or ["ctrl+b"]

    out: list[str] = []
    out.append("")
    out.append("  " + C("1;36", "herdr keybindings") + C("2", f"   prefix = {prefix[0]}"))
    out.append("  " + C("2", "effective set: herdr defaults + ~/.config/herdr/config.toml"))
    out.append("")

    seen_groups: list[str] = []
    for group, _, _ in CATALOG:
        if group not in seen_groups:
            seen_groups.append(group)

    for group in seen_groups:
        rows = []
        for g, action, label in CATALOG:
            if g != group:
                continue
            ks = chords(effective.get(action))
            if not ks:
                continue
            rows.append((" / ".join(ks), label))
        if not rows:
            continue
        out.append("  " + C("1;33", group.upper()))
        width = max(len(k) for k, _ in rows)
        for keys_str, label in rows:
            out.append(f"    {C('1;32', keys_str.ljust(width))}  {C('0', label)}")
        out.append("")

    if commands:
        out.append("  " + C("1;33", "COMMANDS & PLUGINS"))
        rows = [
            (c.get("key", "?"), c.get("description") or c.get("command", ""))
            for c in commands
            if isinstance(c, dict)
        ]
        width = max(len(k) for k, _ in rows)
        for keys_str, label in rows:
            out.append(f"    {C('1;32', keys_str.ljust(width))}  {C('0', label)}")
        out.append("")

    nav_rows = [(" / ".join(chords(effective.get(a))), lbl) for a, lbl in NAVIGATE]
    nav_rows = [r for r in nav_rows if r[0]]
    if nav_rows:
        out.append("  " + C("1;33", "NAVIGATE MODE") + C("2", "  (inside the space picker)"))
        width = max(len(k) for k, _ in nav_rows)
        for keys_str, label in nav_rows:
            out.append(f"    {C('1;32', keys_str.ljust(width))}  {C('0', label)}")
        out.append("")

    text = "\n".join(out)

    # Page it: the sheet is taller than a popup. No -F: that quits when the
    # content fits, which in a popup means it flashes and vanishes. Always wait
    # for q.
    if not plain and sys.stdout.isatty() and shutil.which("less"):
        pager = subprocess.Popen(["less", "-R"], stdin=subprocess.PIPE)
        try:
            pager.communicate(text.encode())
        except BrokenPipeError:
            pass
        return pager.returncode or 0

    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
