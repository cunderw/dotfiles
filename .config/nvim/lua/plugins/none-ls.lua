return {
  -- none-ls is in the spec only because flutter-bloc needs it for its "wrap with
  -- Bloc*" code actions (see bloc.lua). LazyVim warns at startup when none-ls is
  -- present without the lsp.none-ls extra, so that extra is now enabled in
  -- lazyvim.json. The extra registers none-ls as a formatter at priority 200,
  -- above conform, so every none-ls formatting source (stylua from the extra,
  -- prettier from the prettier extra) would take those filetypes away from
  -- conform. Drop the formatting sources so none-ls resolves to no formatter and
  -- conform stays primary. Diagnostics and code actions are kept.
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local FORMATTING = require("null-ls.methods").internal.FORMATTING

      -- A builtin's `method` is either a single method or a list of them.
      local function is_formatter(source)
        local method = source.method
        if type(method) == "table" then
          return vim.tbl_contains(method, FORMATTING) or method[FORMATTING] ~= nil
        end
        return method == FORMATTING
      end

      opts.sources = vim.tbl_filter(function(source)
        return not is_formatter(source)
      end, opts.sources or {})
    end,
  },
}
