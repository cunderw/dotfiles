require("plugins.lualine").config()
require("plugins.treesitter").config()

-- ==================
-- Additional plugins
-- ==================
lvim.plugins = {
  -- Appearance
  { "Mofiqul/dracula.nvim" },
  { "folke/tokyonight.nvim" },
  { "itchyny/vim-highlighturl",
    event = "BufRead",
  },
  -- Utils
  { "christoomey/vim-tmux-navigator" },
  { "vimpostor/vim-tpipeline" },
  -- Misc Dev
  { "lukas-reineke/indent-blankline.nvim" },
  { "norcalli/nvim-colorizer.lua" },
  { "p00f/nvim-ts-rainbow" },
  { "preservim/vimux" },
  {
    "puremourning/vimspector",
    cmd = { "VimspectorInstall", "VimspectorUpdate" },
    fn = { "vimspector#Launch()", "vimspector#ToggleBreakpoint", "vimspector#Continue" },
    config = function()
      require("plugins.vimspector").config()
    end,
  },
  -- Golang
  { "benmills/vimux-golang" },
  { "fatih/vim-go" },
  { "rfratto/vim-go-testify" },
  { "sebdah/vim-delve" },
}

-- ==================
-- Pluin Setup
-- ==================
require("indent_blankline").setup {
  space_char_blankline = " ",
  show_current_context = true,
  show_current_context_start = true,
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

local lspconfig = require 'lspconfig'
lspconfig.gopls.setup {
  settings = {
    gopls = {
      env = { GOFLAGS = "-tags=integration" },
    },
  }
}
