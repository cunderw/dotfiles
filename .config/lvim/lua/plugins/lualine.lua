local Lualine = {}

Lualine.config = function()
  if not lvim.builtin.lualine.active then
    return
  end

  vim.g.tpipeline_autoembed = 0
  lvim.builtin.lualine.style = "default"
  lvim.builtin.lualine.options.section_separators = { left = '', right = '' }
  lvim.builtin.lualine.options.component_separators = '|'
  lvim.builtin.lualine.options.disabled_filetypes = { "alpha", "NvimTree", "Outline" }
  lvim.builtin.lualine.sections.lualine_a = {
    { 'mode', separator = { left = '' }, right_padding = 2 },
  }
  lvim.builtin.lualine.sections.lualine_b = {
    { 'branch', right_padding = 2 },
    { 'filename', separator = { right = '' }, right_padding = 2 },
  }
  lvim.builtin.lualine.sections.lualine_c = {
    { 'diff' }
  }
  lvim.builtin.lualine.sections.lualine_x = {
    { "lsp" }
  }
  lvim.builtin.lualine.sections.lualine_y = {
    { 'location', right_padding = 2 },
    { 'treesitter', right_padding = 2 },
  }
  lvim.builtin.lualine.sections.lualine_z = {
    { 'filetype', separator = { right = '' }, right_padding = 2 },
  }

end

return Lualine
