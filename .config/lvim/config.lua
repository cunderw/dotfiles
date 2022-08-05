--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- general
lvim.log.level = "debug"
lvim.format_on_save = true
lvim.colorscheme = "tokyonight"
lvim.transparent_window = true
lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.section_separators = {left = '', right = '' }

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
  "go",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

--  Plugins
lvim.plugins = {
  { "Mofiqul/dracula.nvim" },
  { "folke/tokyonight.nvim" },
  { "christoomey/vim-tmux-navigator" },
  { "vimpostor/vim-tpipeline" },
}

