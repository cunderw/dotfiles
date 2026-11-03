return {
  "myakove/homeassistant-nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  event = { "BufRead", "BufNewFile" },
  config = function()
    require("homeassistant").setup({
      -- only activate for files under this HA config checkout
      paths = { "home-assistant/" },
      lsp = {
        enabled = true,
        cmd = { "homeassistant-lsp", "--stdio" },
        filetypes = { "yaml", "yaml.homeassistant" },
        settings = {
          homeassistant = {
            host = os.getenv("HA_WS_HOST") or "ws://homeassistant.local:8123/api/websocket",
            token = os.getenv("HA_TOKEN"),
            timeout = 5000,
          },
          cache = {
            enabled = true,
            ttl = 300,
          },
          diagnostics = {
            enabled = true,
            debounce = 500,
          },
        },
      },
      keymaps = {
        dashboard = "<leader>hd",
        picker = "<leader>hp",
        reload_cache = "<leader>hr",
        debug = "<leader>hD",
        edit_dashboard = "<leader>he",
      },
    })
  end,
}
