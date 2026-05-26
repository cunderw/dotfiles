return {
  {
    "akinsho/flutter-tools.nvim",
    config = function(_, opts)
      require("flutter-tools").setup(opts)

      -- Explicitly register dart adapter (flutter-tools registers it lazily after LSP attach)
      local dap = require("dap")
      dap.adapters.dart = {
        type = "executable",
        command = "flutter",
        args = { "debug_adapter" },
      }

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("DartOnSaveActions", { clear = true }),
        pattern = "*.dart",
        callback = function()
          local clients = vim.lsp.get_clients({ bufnr = 0, name = "dartls" })
          if #clients == 0 then return end
          local encoding = clients[1].offset_encoding or "utf-16"
          for _, action_kind in ipairs({ "source.fixAll", "source.organizeImports" }) do
            local params = vim.lsp.util.make_range_params(0, encoding)
            params.context = { only = { action_kind }, diagnostics = {} }
            local results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 2000)
            for _, res in pairs(results or {}) do
              for _, action in pairs(res.result or {}) do
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, encoding)
                end
              end
            end
          end
        end,
      })
    end,
    opts = {
      debugger = {
        enabled = true,
        run_via_dap = true,
        exception_breakpoints = {},
      },
    },
  },
}
