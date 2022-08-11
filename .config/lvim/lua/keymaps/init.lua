lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.which_key.mappings["v"] = {
  name = "Vimspector",
  I = { "<cmd>VimspectorInstall<cr>", "Install" },
  U = { "<cmd>VimspectorUpdate<cr>", "Update" },
  R = { "<cmd>call vimspector#RunToCursor()<cr>", "Run to Cursor" },
  c = { "<cmd>call vimspector#Continue()<cr>", "Continue" },
  i = { "<cmd>call vimspector#StepInto()<cr>", "Step Into" },
  o = { "<cmd>call vimspector#StepOver()<cr>", "Step Over" },
  s = { "<cmd>call vimspector#Launch()<cr>", "Start" },
  t = { "<cmd>call vimspector#ToggleBreakpoint()<cr>", "Toggle Breakpoint" },
  u = { "<cmd>call vimspector#StepOut()<cr>", "Step Out" },
  S = { "<cmd>call vimspector#Stop()<cr>", "Stop" },
  r = { "<cmd>call vimspector#Restart()<cr>", "Restart" },
  x = { "<cmd>VimspectorReset<cr>", "Reset" },
  H = { "<cmd>lua require('config.vimspector').toggle_human_mode()<cr>", "Toggle HUMAN mode" },
}
