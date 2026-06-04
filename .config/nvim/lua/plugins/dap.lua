return {
  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {
      controls = { enabled = true, element = "repl" }, -- clickable step/continue toolbar in REPL winbar
      expand_lines = true,
      render = { max_value_lines = 100, indent = 1 },
      floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
      layouts = {
        {
          position = "left",
          size = 42,
          elements = {
            { id = "scopes", size = 0.35 }, -- local/global variables
            { id = "watches", size = 0.20 },
            { id = "stacks", size = 0.25 }, -- call stack
            { id = "breakpoints", size = 0.20 },
          },
        },
        {
          position = "bottom",
          size = 12,
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 }, -- program stdout (Go / Flutter)
          },
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

      -- Breakpoint + stopped-line signs (use Diagnostic*/Visual groups so they track the colorscheme)
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      sign("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      sign("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      sign("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", linehl = "", numhl = "" })
      sign("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual", numhl = "DiagnosticOk" })

      -- Label each pane with a centered title in its winbar. dapui reuses element
      -- buffers but makes new windows each open, so use BufWinEnter (fires on every
      -- re-display), not FileType (fires once). REPL is omitted: it shows the controls.
      -- Icons are Nerd Font codepoints; nr2char keeps the source ASCII so the bytes are exact.
      local function ic(cp)
        return vim.fn.nr2char(cp, 1)
      end
      local pane_titles = {
        dapui_scopes = ic(0xf1b2) .. " Scopes", -- nf-fa-cube
        dapui_watches = ic(0xf06e) .. " Watches", -- nf-fa-eye
        dapui_stacks = ic(0xf24d) .. " Call Stack", -- nf-fa-clone
        dapui_breakpoints = ic(0xf111) .. " Breakpoints", -- nf-fa-circle (matches the breakpoint sign)
        dapui_console = ic(0xf120) .. " Console", -- nf-fa-terminal
      }
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("dapui_pane_titles", { clear = true }),
        callback = function(args)
          local title = pane_titles[vim.bo[args.buf].filetype]
          if not title then
            return
          end
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            vim.wo[win].winbar = "%=" .. title .. "%="
          end
        end,
      })

      -- Auto-open/close UI with debug sessions
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Virtual text (inline variable values while debugging)
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      highlight_changed_variables = true,
      show_stop_reason = true,
      virt_text_pos = "inline", -- nvim 0.10+; switch to "eol" on older versions
      all_frames = false,
      display_callback = function(variable, _buf, _stackframe, _node, options)
        if options.virt_text_pos == "inline" then
          return " = " .. variable.value
        end
        return variable.name .. " = " .. variable.value
      end,
    },
  },

  -- Persist breakpoints across restarts. Breakpoints must be set via this plugin's
  -- API to be saved, so the breakpoint keymaps are routed through it here.
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost",
    keys = {
      {
        "<leader>db",
        function()
          require("persistent-breakpoints.api").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint (persistent)",
      },
      {
        "<leader>dB",
        function()
          require("persistent-breakpoints.api").set_conditional_breakpoint()
        end,
        desc = "Conditional Breakpoint (persistent)",
      },
      {
        "<leader>dX",
        function()
          require("persistent-breakpoints.api").clear_all_breakpoints()
        end,
        desc = "Clear All Breakpoints",
      },
    },
    config = function()
      require("persistent-breakpoints").setup({ load_breakpoints_event = { "BufReadPost" } })
    end,
  },

  -- Telescope pickers for DAP: :Telescope dap {list_breakpoints,frames,variables,commands,configurations}
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("telescope").load_extension("dap")
    end,
  },

  -- Go debugger (installs delve via Mason)
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    keys = {
      {
        "<leader>dg",
        function()
          require("dap-go").debug_test()
        end,
        desc = "Debug nearest Go test",
      },
      {
        "<leader>dG",
        function()
          require("dap-go").debug_last_test()
        end,
        desc = "Debug last Go test",
      },
    },
  },
}
