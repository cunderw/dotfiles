require("plugins.lualine").config()
require("plugins.treesitter").config()
require("plugins.bufferline").config()
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
  -- Navigation
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },
  {
    'simrat39/symbols-outline.nvim',
    config = function()
      require("plugins.outline").config()
    end,
  },
  -- Misc Dev
  { "lukas-reineke/indent-blankline.nvim" },
  { "norcalli/nvim-colorizer.lua",
    config = function()
      require("plugins.colorizer").config()
    end,
  },
  { "majutsushi/tagbar",
    cmd = { "TagbarToggle" },
  },
  { "p00f/nvim-ts-rainbow" },
  { "preservim/vimux" },
  { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' },
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
