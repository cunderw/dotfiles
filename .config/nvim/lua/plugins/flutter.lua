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
