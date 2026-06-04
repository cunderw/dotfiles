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

      local save_group = vim.api.nvim_create_augroup("DartOnSaveActions", { clear = true })

      -- On save: apply fixAll + organizeImports via dartls (runs before the write).
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = save_group,
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

      -- On save: hot reload, but only when a Flutter app is actually running (no noise otherwise).
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = save_group,
        pattern = "*.dart",
        callback = function()
          local ok, commands = pcall(require, "flutter-tools.commands")
          if ok and commands.is_running() then vim.cmd("FlutterReload") end
        end,
      })

      -- Inline color swatches via the native (0.12+) document-color API. flutter-tools
      -- advertises the documentColor capability, so dartls returns them; its own (deprecated)
      -- lsp.color stays off.
      local function enable_dart_colors(buf)
        if vim.lsp.document_color and vim.lsp.document_color.enable then
          pcall(vim.lsp.document_color.enable, true, buf)
        end
      end
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("DartDocumentColor", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "dartls" then enable_dart_colors(args.buf) end
        end,
      })
      -- Cover any dartls client that attached before this autocmd was registered.
      for _, client in ipairs(vim.lsp.get_clients({ name = "dartls" })) do
        for _, buf in ipairs(vim.lsp.get_buffers_by_client_id(client.id)) do
          enable_dart_colors(buf)
        end
      end
    end,
    opts = {
      debugger = {
        enabled = true,
        run_via_dap = true,
        exception_breakpoints = {},
      },
      -- With run_via_dap, app output already shows in dap-ui's console/repl, so
      -- disable flutter-tools' own __FLUTTER_DEV_LOG__ split to stop it auto-opening.
      dev_log = { enabled = false },
      -- Visual indent guides through the widget tree.
      widget_guides = { enabled = true },
      -- Surface the running device + app version (rendered by the lualine component below).
      decorations = {
        statusline = { app_version = true, device = true },
      },
      -- Extra dartls analysis settings, deep-merged with flutter-tools' defaults (which already
      -- enable completeFunctionCalls, showTodos, updateImportsOnRename and exclude the SDK dirs).
      lsp = {
        settings = {
          renameFilesWithClasses = "prompt", -- offer to rename the file when its class is renamed
          enableSnippets = true,
        },
      },
    },
  },

  -- Show the running Flutter device + app version in the statusline.
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local function flutter_status()
        local d = vim.g.flutter_tools_decorations
        if type(d) ~= "table" then return "" end
        local parts = {}
        if type(d.app_version) == "string" and d.app_version ~= "" then
          parts[#parts + 1] = d.app_version
        end
        if d.device then
          local name = type(d.device) == "table" and (d.device.name or d.device.id) or tostring(d.device)
          if name and name ~= "" then parts[#parts + 1] = name end
        end
        return table.concat(parts, "  ")
      end

      local icon
      local ok, MiniIcons = pcall(require, "mini.icons")
      if ok then icon = MiniIcons.get("filetype", "dart") end

      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, 1, {
        flutter_status,
        cond = function() return flutter_status() ~= "" end,
        icon = icon,
      })
    end,
  },
}
