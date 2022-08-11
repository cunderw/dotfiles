require("plugins.lualine").config()
require("plugins.treesitter").config()

-- ==================
-- Additional plugins
-- ==================
lvim.plugins = {
  --
  -- Debug
  --
  {
    "puremourning/vimspector",
    cmd = { "VimspectorInstall", "VimspectorUpdate" },
    fn = { "vimspector#Launch()", "vimspector#ToggleBreakpoint", "vimspector#Continue" },
    config = function()
      require("plugins.vimspector").config()
    end,
  },
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
  { "norcalli/nvim-colorizer.lua",
    config = function()
      require("plugins.colorizer").config()
    end,
  },
  { "p00f/nvim-ts-rainbow" },
  { "preservim/vimux" },
  -- Golang
  { "benmills/vimux-golang" },
  { "fatih/vim-go" },
  { "rfratto/vim-go-testify" },
  { "sebdah/vim-delve" },
}

-- ==================
-- Pluin Setup
-- ==================
local lspconfig = require 'lspconfig'
lspconfig.gopls.setup {
  settings = {
    gopls = {
      env = { GOFLAGS = "-tags=integration" },
    },
  }
}
