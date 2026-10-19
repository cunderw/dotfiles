return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              customTags = {
                "!include scalar",
                "!include_dir_list scalar",
                "!include_dir_named scalar",
                "!include_dir_merge_list scalar",
                "!include_dir_merge_named scalar",
                "!secret scalar",
                "!env_var scalar",
                "!input scalar",
              },
            },
          },
        },
        marksman = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function(_, result, ctx)
              local uri = result.uri or ""
              -- atc-connect-flutter's instruction docs cross-link the same
              -- filename from multiple dirs (e.g. coding-style.instructions.md
              -- under both .claude/ and .github/instructions/), which
              -- marksman can't disambiguate and has no config toggle for.
              -- It also misresolves some ../../instructions/*.instructions.md
              -- links from .github/skills/*/SKILL.md as broken even though
              -- the target files exist and the relative path is correct
              -- (confirmed not index staleness — persists after LspRestart).
              if uri:match("/Dev/wwt/custom%-apps/atc%-connect%-flutter/") then
                result.diagnostics = vim.tbl_filter(function(d)
                  local msg = tostring(d.message)
                  return not msg:match("^Ambiguous link to document")
                    and not msg:match("^Link to non%-existent document")
                end, result.diagnostics)
              end
              vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx)
            end,
          },
        },
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
