return {
  -- Bloc/Cubit generation + "wrap with BlocBuilder/Provider/Listener/..." code actions.
  {
    "wa11breaker/flutter-bloc.nvim",
    dependencies = { "nvimtools/none-ls.nvim" },
    ft = "dart",
    opts = {
      bloc_type = "default", -- 'default' | 'equatable' | 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    },
    config = function(_, opts)
      -- flutter-bloc registers its "wrap with Bloc*" actions as a none-ls code-action
      -- source but assumes none-ls is already initialized, so set it up first.
      require("null-ls").setup()
      require("flutter-bloc").setup(opts)
    end,
  },
}
