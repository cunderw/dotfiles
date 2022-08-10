local Vimspector = {}

Vimspector.config = function()
  --
  -- https://github.com/puremourning/vimspector
  --
  vim.g.vimspector_enable_mappings = "HUMAN"
  vim.g.vimspector_install_gadgets = { 'debugpy', 'vscode-go', 'CodeLLDB' }
  vim.g.vimspector_base_dir = '$HOME/.local/share/lunarvim/site/pack/packer/opt/vimspector'
end

return Vimspector
