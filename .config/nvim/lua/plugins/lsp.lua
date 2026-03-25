return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function(_, result, ctx)
              local uri = result.uri or ""
              if uri:match("%.js$") or uri:match("%.jsx$") then
                local dominated = { [80001] = true, [7016] = true }
                result.diagnostics = vim.tbl_filter(function(d)
                  return not dominated[d.code]
                end, result.diagnostics)
              end
              vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx)
            end,
          },
        },
      },
    },
  },
}
