return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },
    opts = {
      enhanced_diff_hl = true, -- richer +/- highlighting in the diff
    },
    -- <leader>gd / gD and the <leader>gh* range are taken by LazyVim, so group under gv ("diff view")
    keys = {
      { "<leader>gvo", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (working tree)" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gvf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current file)" },
      { "<leader>gvr", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
    },
  },
}
