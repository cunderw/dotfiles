// ctrl-b shift-d: builds the dev layout around the focused pane (scripts/dev-layout.sh).
import { View, div } from "gpui-kit";
import { appHome, closeOverlay, exec, focused, props } from "herdr";

export default class DevLayout extends View {
  init(_props, cx) {
    const { pane, terminal, tab, space, cwd } = focused() ?? {};
    cx.spawn(async () => {
      const r = await exec(`${appHome()}/scripts/dev-layout.sh`, [pane, terminal, tab, space, cwd]);
      if (r.code !== 0) console.log(`dev-layout: ${r.stderr}`);
      closeOverlay(props().overlay);
    });
  }

  render() {
    return div();
  }
}
