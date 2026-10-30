const MODS = { ctrl: "⌃", shift: "⇧", alt: "⌥", cmd: "⌘" };
const NAMES = {
  tab: "⇥", enter: "↩", backspace: "⌫", escape: "⎋", space: "␣",
  left: "←", right: "→", up: "↑", down: "↓",
  pageup: "PgUp", pagedown: "PgDn", home: "Home", end: "End",
};

function stroke(s) {
  let out = "";
  for (;;) {
    const i = s.indexOf("-");
    if (i <= 0 || i === s.length - 1 || !(s.slice(0, i) in MODS)) break;
    out += MODS[s.slice(0, i)];
    s = s.slice(i + 1);
  }
  return out + (NAMES[s] ?? (s.length === 1 ? s.toUpperCase() : s[0].toUpperCase() + s.slice(1)));
}

export const chord = (keys) => keys.trim().split(/\s+/).map(stroke).join(" ");

const firstSentence = (s) => {
  const m = s.match(/^(.*?[.!?])(\s|$)/);
  return (m ? m[1] : s).trim();
};

export function describe(recipe, mainJs) {
  if (recipe) {
    const lines = recipe.split("\n");
    const title = lines.findIndex((l) => /^#\s/.test(l));
    const para = [];
    for (const l of lines.slice(title + 1)) {
      if (!l.trim()) { if (para.length) break; continue; }
      if (/^[#!]/.test(l.trim())) { if (para.length) break; continue; }
      para.push(l.trim());
    }
    if (para.length) return firstSentence(para.join(" "));
  }
  if (mainJs) {
    const comment = [];
    for (const l of mainJs.split("\n")) {
      const m = l.match(/^\s*\/\/\s?(.*)$/);
      if (!m) break;
      comment.push(m[1].trim());
    }
    const text = comment.join(" ").replace(/^(?:(?:ctrl|cmd|alt|shift)-[^\s:]+\s*)+:\s*/, "");
    if (text) return firstSentence(text[0].toUpperCase() + text.slice(1));
  }
  return "";
}

function target(action, user, self) {
  let m = action.match(/^mod\.open:(.+)$/);
  if (m && user.has(m[1])) return { mod: m[1], label: "open" };
  m = action.match(/^layout\.(toggle|show):(.+)$/);
  if (m && m[2] === self) return { mod: self, label: m[1] };
  m = action.match(/^([\w-]+)\.([\w-]+)$/);
  if (m && user.has(m[1])) return { mod: m[1], label: m[2] };
  return null;
}

// keysJson: parsed keys.json; mods: [{name, description}] for every user mod; layout: the shown layout's name.
export function buildRows(keysJson, mods, { self = "mod-keys", layout = null } = {}) {
  const user = new Set(mods.map((m) => m.name));
  const sections = ["global", "terminal", ...(layout ? [`layout:${layout}`] : [])];
  const seen = new Set();
  const byMod = new Map();
  for (const section of sections) {
    for (const [keys, action] of Object.entries(keysJson?.[section] ?? {})) {
      const t = target(action, user, self);
      if (!t || seen.has(`${keys}\0${action}`)) continue;
      seen.add(`${keys}\0${action}`);
      if (!byMod.has(t.mod)) byMod.set(t.mod, []);
      byMod.get(t.mod).push({ keys, chord: chord(keys), action, label: t.label, section });
    }
  }
  const desc = new Map(mods.map((m) => [m.name, m.description ?? ""]));
  const groups = [...byMod.keys()].filter((n) => n !== self).sort().map((mod) => ({
    mod, description: desc.get(mod) ?? "",
    bindings: byMod.get(mod).sort((a, b) => a.label.localeCompare(b.label) || a.keys.localeCompare(b.keys)),
  }));
  const noKey = mods.filter((m) => m.name !== self && !byMod.has(m.name))
    .sort((a, b) => a.name.localeCompare(b.name))
    .map((m) => ({ mod: m.name, description: m.description ?? "" }));
  const toggle = (byMod.get(self) ?? []).map((b) => b.chord);
  return { groups, noKey, toggle: [...new Set(toggle)] };
}

export function userModNames(entries, installed, self = "mod-keys") {
  const shipped = new Set(Object.keys(installed ?? {}));
  return entries.filter((n) => !n.startsWith(".") && !shipped.has(n) && n !== self).sort();
}
