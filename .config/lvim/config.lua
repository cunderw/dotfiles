-- Shorter ASCII art logo, so not too much space is taken up.
lvim.builtin.alpha.dashboard.section.header.val = {
  "▌              ▌ ▌▗",
  "▌  ▌ ▌▛▀▖▝▀▖▙▀▖▚▗▘▄ ▛▚▀▖",
  "▌  ▌ ▌▌ ▌▞▀▌▌  ▝▞ ▐ ▌▐ ▌",
  "▀▀▘▝▀▘▘ ▘▝▀▘▘   ▘ ▀▘▘▝ ▘",
}

require("plugins")
require("keymaps")
-- General LunarVim Configs
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"
lvim.transparent_window = true
lvim.termguicolors = true

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
--lvim.builtin.dap.active = true


-- Misc Configs
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.showtabline = 2
vim.opt.title = true -- set the title of window to the value of the titlestring
vim.opt.titlestring = "%<%F%=%l/%L - nvim"
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.cmd "set laststatus=0"
