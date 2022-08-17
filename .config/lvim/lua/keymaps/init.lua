lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.which_key.mappings["v"] = {
  name = "Vimspector",
  I = { "<cmd>VimspectorInstall<cr>", "Install" },
  U = { "<cmd>VimspectorUpdate<cr>", "Update" },
  R = { "<cmd>call vimspector#RunToCursor()<cr>", "Run to Cursor" },
  c = { "<cmd>call vimspector#Continue()<cr>", "Continue" },
  i = { "<cmd>call vimspector#StepInto()<cr>", "Step Into" },
  o = { "<cmd>call vimspector#StepOver()<cr>", "Step Over" },
  s = { "<cmd>call vimspector#Launch()<cr>", "Start" },
  t = { "<cmd>call vimspector#ToggleBreakpoint()<cr>", "Toggle Breakpoint" },
  u = { "<cmd>call vimspector#StepOut()<cr>", "Step Out" },
  S = { "<cmd>call vimspector#Stop()<cr>", "Stop" },
  r = { "<cmd>call vimspector#Restart()<cr>", "Restart" },
  x = { "<cmd>VimspectorReset<cr>", "Reset" },
  H = { "<cmd>lua require('config.vimspector').toggle_human_mode()<cr>", "Toggle HUMAN mode" },
}

lvim.builtin.which_key.mappings["l"] = {
  name = "LSP",
  I = { "<cmd>Mason<cr>", "Mason Info" },
  R = { vim.lsp.buf.references, "References" },
  S = { "<cmd>Telescope lsp_dynamic", "Workspace Symbols" },
  a = { vim.lsp.buf.code_action, "Code Action" },
  d = { vim.lsp.buf.definition, "Goto Definition" },
  e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
  f = { vim.lsp.buf.formatting, "Format" },
  h = { vim.lsp.buf.hover, "Hover" },
  i = { "<cmd>LspInfo<cr>", "Info" },
  j = { vim.diagnostic.goto_next, "Next Diagnostic" },
  k = { vim.diagnostic.goto_prev, "Prev Diagnostic" },
  l = { vim.lsp.codelens.run, "CodeLens Action" },
  q = { vim.diagnostic.setloclist, "Quickfix" },
  r = { vim.lsp.buf.rename, "Rename" },
  s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
  t = { vim.lsp.buf.type_definition, "Type Definition" },
  w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
  p = {
    name = "Peek",
    d = { "<cmd>lua require('lvim.lsp.peek').Peek('definition')<cr>", "Definition" },
    t = { "<cmd>lua require('lvim.lsp.peek').Peek('typeDefinition')<cr>", "Type Definition" },
    i = { "<cmd>lua require('lvim.lsp.peek').Peek('implementation')<cr>", "Implementation" },
  },
}

lvim.builtin.which_key.mappings["b"] = {
  name = "Buffers",
  j = { "<cmd>BufferLinePick<cr>", "Jump" },
  f = { "<cmd>Telescope buffers<cr>", "Find" },
  b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
  n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
  e = {
    "<cmd>BufferLinePickClose<cr>",
    "Pick which buffer to close",
  },
  h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
  l = {
    "<cmd>BufferLineCloseRight<cr>",
    "Close all to the right",
  },
  D = {
    "<cmd>BufferLineSortByDirectory<cr>",
    "Sort by directory",
  },
  L = {
    "<cmd>BufferLineSortByExtension<cr>",
    "Sort by language",
  },
}


lvim.builtin.which_key.mappings["n"] = {
  name = "Navigation",
  h = { "<cmd>HopWord<cr>", "Hop" },
  o = { "<cmd>SymbolsOutline<cr>", "Outline" },
}

lvim.builtin.which_key.mappings["S"] = {
  name = "Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}
