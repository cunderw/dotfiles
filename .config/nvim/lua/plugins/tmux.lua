-- Owns <C-h/j/k/l> only OUTSIDE herdr. Inside a herdr pane, herdr-splits.nvim
-- takes them (see plugins/herdr-splits.lua) — the two `cond`s are inverses, so
-- exactly one plugin claims these keys in each multiplexer.
--
-- Keep the `keys` table: LazyVim's safe_keymap_set skips any lhs already
-- claimed by a lazy keys handler, so these entries are what prevent LazyVim
-- binding <C-h/j/k/l> to <C-w>h/j/k/l on VeryLazy. Removing them hands the keys
-- to LazyVim, which is a silent break — the plugin still loads, the keys just
-- stop reaching it.
return {
  "christoomey/vim-tmux-navigator",
  cond = vim.env.HERDR_ENV ~= "1",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
