// Runs lazygit in a popup in the focused pane's folder, then gets out of the way.
import { View, div } from "gpui-kit";
import { closeOverlay, focused, hc, openOverlay, props, run } from "herdr";

const WIDTH = 0.8, HEIGHT = 0.8;
const argv = (terminal) => ["lazygit"];

export default class Popup extends View {
  init(_props, cx) {
    const { cwd, terminal } = focused() ?? {};
    cx.spawn(async (cx) => {
      const r = await hc(["run", "--bg", "--json", "--rm", "--no-parent", ...(cwd ? ["--cwd", cwd] : []), "--", ...argv(terminal)]);
      closeOverlay(props().overlay);
      if (r.code !== 0) return console.log(`popup: ${r.stderr}`);
      const { address } = JSON.parse(r.stdout);
      openOverlay({ kind: "dialog", width: WIDTH, height: HEIGHT, layout: { type: "block", content: { terminal: address } } });
      await cx.sleep(100);
      run("pane.focus", { terminal: address });
    });
  }

  render() {
    return div();
  }
}
