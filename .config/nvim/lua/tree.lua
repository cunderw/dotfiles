require'nvim-tree'.setup {
  auto_close = true,
  view = {
   side='right',
   auto_resize = false,
  }
}

require'nvim-web-devicons'.setup {
 override = {
  zsh = {
    icon = "",
    color = "#428850",
    name = "Zsh"
  }
 };
 default = true;
}
