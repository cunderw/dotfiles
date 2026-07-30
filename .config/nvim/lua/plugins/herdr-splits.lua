-- Seamless navigation + resizing between Neovim splits and herdr panes.
-- Replaces the vim-herdr-navigation + after/plugin approach.
--
-- The `keys` table is load-bearing, not just a lazy-load trigger: LazyVim's
-- safe_keymap_set skips any lhs already claimed by a lazy keys handler ("do not
-- create the keymap if a lazy keys handler exists"), so declaring <C-h/j/k/l>
-- here is what stops LazyVim binding them to <C-w>h/j/k/l on VeryLazy.
--
-- `cond` scopes this to herdr only; vim-tmux-navigator takes the inverse cond
-- so exactly one plugin owns these keys in each multiplexer.
return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  config = function()
    require("herdr-splits").setup({
      -- Defaults are fine: the stock ignore lists already cover neo-tree and
      -- snacks (explorer/picker/dashboard), which is the main reason for
      -- switching — plain `wincmd h` traps focus inside those sidebars.
      at_edge = "wrap",
      unzoom_on_nav = true,
    })
  end,
  keys = {
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end, desc = "Navigate left (nvim/herdr)" },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end, desc = "Navigate down (nvim/herdr)" },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end, desc = "Navigate up (nvim/herdr)" },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Navigate right (nvim/herdr)" },
    -- Resize is on alt+SHIFT+hjkl, not the upstream default alt+hjkl:
    -- mini.move (ships with LazyVim) owns <M-h/j/k/l> for line movement.
    { "<M-H>", function() require("herdr-splits").resize_left() end, desc = "Resize left" },
    { "<M-J>", function() require("herdr-splits").resize_down() end, desc = "Resize down" },
    { "<M-K>", function() require("herdr-splits").resize_up() end, desc = "Resize up" },
    { "<M-L>", function() require("herdr-splits").resize_right() end, desc = "Resize right" },
  },
}
