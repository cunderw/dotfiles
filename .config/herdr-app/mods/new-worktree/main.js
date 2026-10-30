// ctrl-b ctrl-g: the shipped New worktree dialog, which mod.open can't pass props to.
import { View, div } from "gpui-kit";
import { closeOverlay, focused, openOverlay, props } from "herdr";

export default class NewWorktree extends View {
  init(_props, cx) {
    const { space, cwd } = focused() ?? {};
    cx.spawn(async () => {
      openOverlay({ mod: "worktree", kind: "dialog", width: 460, height: 280, props: { space, folder: cwd, action: "new" } });
      closeOverlay(props().overlay);
    });
  }

  render() {
    return div();
  }
}
