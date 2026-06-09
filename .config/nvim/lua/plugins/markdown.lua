return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.stdpath("config") .. "/.markdownlint.jsonc",
            "-",
          },
        },
      },
    },
  },
  -- LazyVim's markdown extra also registers markdownlint-cli2 as a none-ls
  -- diagnostics source (because none-ls is installed for flutter-bloc). That
  -- invocation runs `markdownlint-cli2 $FILENAME` with no --config, so it
  -- re-flags MD013 with default rules and double-lints alongside nvim-lint.
  -- nvim-lint already covers markdown linting, so drop the redundant source.
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "markdownlint-cli2"
      end, opts.sources or {})
    end,
  },
}
