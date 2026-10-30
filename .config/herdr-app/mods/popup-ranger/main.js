// Runs ranger in a popup in the focused pane's folder, then gets out of the way.
import { View, div } from "gpui-kit";
import { closeOverlay, focused, hc, openOverlay, props } from "herdr";

const WIDTH = 0.8, HEIGHT = 0.8;
const argv = (terminal) => ["ranger"];

export default class Popup extends View {
  init(_props, cx) {
    const { cwd, terminal } = focused() ?? {};
    cx.spawn(async () => {
      const r = await hc(["run", "--bg", "--json", "--rm", "--no-parent", ...(cwd ? ["--cwd", cwd] : []), "--", ...argv(terminal)]);
      if (r.code === 0) openOverlay({ kind: "dialog", width: WIDTH, height: HEIGHT, layout: { type: "block", content: { terminal: JSON.parse(r.stdout).address } } });
      else console.log(`popup: ${r.stderr}`);
      closeOverlay(props().overlay);
    });
  }

  render() {
    return div();
  }
}
