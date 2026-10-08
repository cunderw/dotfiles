-- Resolves the markdownlint config to use for the current buffer: a
-- project-local `.markdownlint.*` (searched upward from the buffer, so a repo
-- can override/extend rules for itself) if one exists, else the global config.
local function markdownlint_config()
  local global = vim.fn.stdpath("config") .. "/.markdownlint.jsonc"
  local found = vim.fs.find(
    { ".markdownlint.jsonc", ".markdownlint.json", ".markdownlint.yaml", ".markdownlint.yml" },
    { path = vim.fn.expand("%:p:h"), upward = true }
  )[1]
  return found or global
end

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            markdownlint_config,
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
