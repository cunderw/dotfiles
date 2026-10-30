// ctrl-h/j/k/l: move through nvim splits and panes as one grid, wrapping at the edges.
// nvim gets the key and comes back through out-<dir> when it runs out of splits.
// Sits in a 0px block so its commands stay live; draws nothing.
import { View, div } from "gpui-kit";
import { focused, hc, nextCommand, panes, run } from "herdr";

const KEY = { left: "h", down: "j", up: "k", right: "l" };
const OPPOSITE = { left: "right", down: "up", up: "down", right: "left" };
const SETTLE_MS = 40; // run() is queued: how long until focused() shows its result
const MAX_PANES = 16;

export default class SmartNav extends View {
  init(_props, cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        if (c in KEY) this.nav(c, cx);
        else if (c.startsWith("out-")) this.leave(c.slice(4), cx);
        else if (c === "cycle-next") this.cycle(1);
        else if (c === "cycle-prev") this.cycle(-1);
      }
    });
  }

  current() {
    const pane = focused()?.pane;
    return panes().find((p) => p.pane === pane);
  }

  nav(dir, cx) {
    const p = this.current();
    if (p?.program?.key === "nvim") hc(["keys", p.terminal, `ctrl+${KEY[dir]}`]);
    else this.leave(dir, cx);
  }

  leave(dir, cx) {
    const p = this.current();
    if (p?.zoomed) run("pane.zoom");
    run("pane.go", { direction: dir });
    cx.timer.after(SETTLE_MS, (cx) => {
      if (focused()?.pane === p?.pane) this.wrap(OPPOSITE[dir], MAX_PANES, cx);
    });
  }

  // At the edge: walk the other way until focus stops moving.
  wrap(dir, left, cx) {
    const from = focused()?.pane;
    run("pane.go", { direction: dir });
    cx.timer.after(SETTLE_MS, (cx) => {
      if (left > 0 && focused()?.pane !== from) this.wrap(dir, left - 1, cx);
    });
  }

  cycle(step) {
    const f = focused();
    const list = panes().filter((p) => p.tab === f?.tab);
    const i = list.findIndex((p) => p.pane === f?.pane);
    if (list.length > 1) run("pane.focus", { pane: list[(i + step + list.length) % list.length].pane });
  }

  render() {
    return div();
  }
}
