-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.g.lazyvim_prettier_needs_config = false

-- Belt-and-suspenders: never let editor-spawned git (neo-tree/gitsigns/etc.) grab the
-- optional .git/index.lock, so it can't race other git operations. (Same as VS Code.)
vim.env.GIT_OPTIONAL_LOCKS = "0"
