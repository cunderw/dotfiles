-- Shorter ASCII art logo, so not too much space is taken up.
lvim.builtin.alpha.dashboard.section.header.val = {
  "▌              ▌ ▌▗",
  "▌  ▌ ▌▛▀▖▝▀▖▙▀▖▚▗▘▄ ▛▚▀▖",
  "▌  ▌ ▌▌ ▌▞▀▌▌  ▝▞ ▐ ▌▐ ▌",
  "▀▀▘▝▀▘▘ ▘▝▀▘▘   ▘ ▀▘▘▝ ▘",
}

-- general
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


lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.section_separators = { left = '', right = '' }
lvim.builtin.lualine.options.component_separators = '|'
lvim.builtin.lualine.sections.lualine_a = {
}
lvim.builtin.lualine.sections.lualine_b = {
  { 'mode', separator = { left = '' }, right_padding = 2 },
  { 'filename', separator = { right = '' }, right_padding = 2 },
}
lvim.builtin.lualine.sections.lualine_c = {
  { 'diff' }
}
lvim.builtin.lualine.sections.lualine_x = {
  { "branch" }
}
lvim.builtin.lualine.sections.lualine_y = {
  { 'location', right_padding = 2 },
  { 'filetype', separator = { right = '' }, right_padding = 2 },
}
lvim.builtin.lualine.sections.lualine_z = {}

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

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
vim.g.tpipeline_autoembed = 0

--  Plugins
lvim.plugins = {
  { "Mofiqul/dracula.nvim" },
  { "folke/tokyonight.nvim" },
  { "christoomey/vim-tmux-navigator" },
  { "vimpostor/vim-tpipeline" },
  {
    "itchyny/vim-highlighturl",
    event = "BufRead",
  },
  {
    "p00f/nvim-ts-rainbow",
  },
  {
    "norcalli/nvim-colorizer.lua",
  },
  {
    "lukas-reineke/indent-blankline.nvim",
  },
}

vim.opt.list = true
vim.opt.listchars:append "space:⋅"

require("indent_blankline").setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
}

require("nvim-treesitter.configs").setup {
  highlight = {
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
  }
}

require("colorizer").setup({ "*" }, {
  names    = true, -- "Name" codes, see https://www.w3schools.com/colors/colors_hex.asp   Blue, HotPink, OldLace, Plum, LightGreen, Coral
  RGB      = true, -- #RGB hex codes                                                      #f0f #FAB
  RRGGBB   = true, -- #RRGGBB hex codes                                                   #ffff00 #FF00FF
  RRGGBBAA = true, -- #RRGGBBAA hex codes                                                 #ffff00ff #AbCdEf
  rgb_fn   = true, -- CSS rgb() and rgba() functions                                      rgb(100,200,50) rgba(255,255,255,1.0) rgb(100%, 0%, 0%)
  hsl_fn   = true, -- CSS hsl() and hsla() functions                                      hsl(120,100%,50%) hsla(20,100%,40%,0.7)
  css      = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
  css_fn   = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
  mode     = 'background'; -- Set the display mode.
})
