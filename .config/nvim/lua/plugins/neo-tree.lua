return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- File tree only — drop the "buffers" and "git_status" source tabs.
    opts.sources = { "filesystem" }
    -- Don't run git status at all: no inline git decorations, no background polling.
    opts.enable_git_status = false

    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    }
  end,
}
