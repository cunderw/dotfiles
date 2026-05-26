local swift_fts = { "swift", "objc", "objcpp" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "swift", "objc" })
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swift_format" },
      },
    },
  },

  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
    },
    ft = swift_fts,
    cmd = {
      "XcodebuildSetup",
      "XcodebuildPicker",
      "XcodebuildBuild",
      "XcodebuildBuildRun",
      "XcodebuildRun",
      "XcodebuildTest",
      "XcodebuildSelectScheme",
      "XcodebuildSelectDevice",
    },
    keys = {
      { "<leader>X", "", desc = "+xcode" },
      { "<leader>Xf", "<cmd>XcodebuildPicker<cr>", desc = "All Xcode actions" },
      { "<leader>Xb", "<cmd>XcodebuildBuild<cr>", desc = "Build" },
      { "<leader>Xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },
      { "<leader>Xt", "<cmd>XcodebuildTest<cr>", desc = "Run tests" },
      { "<leader>XT", "<cmd>XcodebuildTestClass<cr>", desc = "Test current class" },
      { "<leader>Xs", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select scheme" },
      { "<leader>Xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select device" },
      { "<leader>Xp", "<cmd>XcodebuildSelectTestPlan<cr>", desc = "Select test plan" },
      { "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle logs" },
      { "<leader>Xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle coverage" },
    },
    config = function()
      require("xcodebuild").setup({})
      require("xcodebuild.integrations.dap").setup()
    end,
  },
}
