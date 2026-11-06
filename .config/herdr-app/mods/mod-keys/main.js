// Your mods and the keys that open them, so you can remember them.
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { appHome, exec, readTextFile, run, shared, theme, watchFolder } from "herdr";
import * as fs from "fs/promises";
import { buildRows, describe, userModNames } from "./rows.js";

const SELF = "mod-keys";

function perform(action) {
  if (typeof action !== "string") return run(action.command, action.args ?? {});
  let m = action.match(/^mod\.open:(.+)$/);
  if (m) return run("mod.open", { name: m[1] });
  m = action.match(/^layout\.(toggle|show):(.+)$/);
  if (m) return run(`layout.${m[1]}`, { id: m[2] });
  run(action);
}

export default class ModKeys extends View {
  init(_props, cx) {
    this.keys = {};
    this.mods = [];
    cx.spawn(async (cx) => {
      await this.load();
      cx.notify();
      const home = appHome();
      for (;;) {
        const changed = await watchFolder(home);
        if (changed.some((p) => p.endsWith("/keys.json") && !p.includes("/mods/"))) await this.loadKeys();
        if (changed.some((p) => p.startsWith(`${home}/mods/`) && !p.includes(`/mods/${SELF}/`))) await this.loadMods();
        cx.notify();
      }
    });
  }

  async load() {
    await Promise.all([this.loadKeys(), this.loadMods()]);
  }

  async loadKeys() {
    try {
      this.keys = JSON.parse((await readTextFile(`${appHome()}/keys.json`)) ?? "{}");
      this.error = null;
    } catch (e) {
      this.error = `keys.json: ${e.message ?? e}`;
    }
  }

  async loadMods() {
    const home = appHome();
    let installed = {};
    try { installed = JSON.parse((await readTextFile(`${home}/installed.json`)) ?? "{}"); } catch {}
    const names = userModNames(await fs.readdir(`${home}/mods`), installed, SELF);
    this.mods = await Promise.all(names.map(async (name) => {
      const dir = `${home}/mods/${name}`;
      let real = dir;
      try { real = (await exec("readlink", ["-f", dir])).stdout.trim() || dir; } catch {}
      const recipe = real === dir ? null : await readTextFile(`${real}/../../RECIPE.md`).catch(() => null);
      const main = await readTextFile(`${dir}/main.js`).catch(() => null);
      return { name, description: describe(recipe, main) };
    }));
  }

  render() {
    const t = theme();
    const { groups, noKey, toggle } = buildRows(this.keys, this.mods, { self: SELF, layout: shared("layout") });
    const keycap = (text) => div().flex_none().px(6).h(20).rounded(5).bg(t.raised).border_1().border_color(t.border)
      .text_size(11.5).text_color(t.foreground).flex().items_center().child(text);
    const heading = (text) => div().px(8).pt(12).pb(4).text_size(11.5).text_color(t.dim).child(text);
    const modTitle = (mod, description) => v_flex().px(8).pt(10).pb(2).gap(1)
      .child(div().font_semibold().text_color(t.foreground).child(mod))
      .when(Boolean(description), (el) => el.child(div().text_size(11.5).text_color(t.muted).truncate().child(description)));

    const rows = [];
    for (const g of groups) {
      rows.push(modTitle(g.mod, g.description));
      for (const b of g.bindings) {
        rows.push(h_flex().id(`row-${b.section}-${b.keys}-${JSON.stringify(b.action)}`).px(8).h(26).gap(8).items_center().rounded(6)
          .cursor_pointer().hover((s) => s.bg(t.hover))
          .on_click(() => perform(b.action))
          .child(keycap(b.chord))
          .child(div().flex_1().min_w(0).truncate().text_color(t.muted).child(b.label)));
      }
    }
    if (noKey.length) {
      rows.push(heading("No key"));
      for (const m of noKey) rows.push(modTitle(m.mod, m.description));
    }

    return v_flex().id("mod-keys").size_full().min_h(0).rounded(10).overflow_hidden().bg(t.background)
      .border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(36).px(12).flex_none().items_center().justify_between().border_b(1).border_color(t.border)
        .child(div().text_size(11.5).text_color(t.dim).child("Mod keys"))
        .when(toggle.length > 0, (el) => el.child(h_flex().gap(6).items_center().text_size(11).text_color(t.dim)
          .child("hide").child(keycap(toggle[0])))))
      .when(Boolean(this.error), (el) => el.child(div().px(12).py(8).text_size(12).text_color(t.blocked).child(this.error)))
      .child(v_flex().id("mod-keys-list").flex_1().min_h(0).px(6).pb(12).overflow_y_scrollbar().children(rows));
  }
}

