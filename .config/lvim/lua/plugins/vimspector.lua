local Vimspector = {}

Vimspector.config = function()
  --
  -- https://github.com/puremourning/vimspector
  --
  vim.g.vimspector_enable_mappings = "HUMAN"
  vim.g.vimspector_install_gadgets = { 'debugpy', 'vscode-go', 'CodeLLDB', 'vscode-node-debug2' }
  vim.g.vimspector_base_dir = '/Users/cunderw/.local/share/lunarvim/site/pack/packer/opt/vimspector'
end

return Vimspector
