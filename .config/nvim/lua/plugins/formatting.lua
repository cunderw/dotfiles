return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          condition = function(_, ctx)
            return vim.fs.find(
              { ".prettierrc", ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.json", ".prettierrc.yaml", ".prettierrc.yml", "prettier.config.js", "prettier.config.cjs", ".prettierrc.toml" },
              { path = ctx.filename, upward = true }
            )[1] ~= nil
          end,
        },
      },
    },
  },
}
