return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      transparent = true,
      on_highlights = function(hl, c)
        hl.Folded = { bg = "NONE", fg = c.comment }
      end,
    },
  },
}
