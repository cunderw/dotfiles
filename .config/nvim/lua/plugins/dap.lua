return {
  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)

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
    opts = {},
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
