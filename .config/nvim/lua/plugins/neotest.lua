return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "sidlatau/neotest-dart",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-vim-test",
      "vim-test/vim-test",
    },
    opts = {
      adapters = {
        ["neotest-dart"] = {
          command = "flutter",
          use_lsp = true,
        },
        -- Native JS/TS adapters (rich per-test trees). Each self-scopes to its own
        -- project type via root detection, so they don't fight each other.
        ["neotest-vitest"] = {},
        ["neotest-jest"] = {},
        -- Ava has no native adapter, so route it through vim-test. Scoped to JS/TS so it
        -- never claims Go/Dart/etc. (those are handled by their own adapters above).
        ["neotest-vim-test"] = {
          allow_file_types = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        },
      },
    },
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      -- resolve adapter opts
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        local adapter = require(name)
        if type(config) == "table" and not vim.tbl_isempty(config) then
          if type(adapter) == "table" and adapter.setup then
            adapter.setup(config)
          else
            -- function or callable table (e.g. neotest-vim-test, neotest-dart): configure by calling
            adapter = adapter(config)
          end
        end
        adapters[#adapters + 1] = adapter
      end

      opts.adapters = adapters
      require("neotest").setup(opts)
    end,
    keys = {},
  },
}
