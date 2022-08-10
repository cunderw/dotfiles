local Treesitter = {}

Treesitter.config = function()
  lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "c",
    "c_sharp",
    "comment",
    "cpp",
    "css",
    "dockerfile",
    "go",
    "html",
    "http",
    "java",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "python",
    "rust",
    "scss",
    "svelte",
    "toml",
    "tsx",
    "tsx",
    "typescript",
    "vim",
    "vue",
    "yaml",
  }
  lvim.builtin.treesitter.highlight.enabled = true


  require("nvim-treesitter.configs").setup {
    highlight = {
    },
    rainbow = {
      enable = true,
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = nil, -- Do not enable for files with more than n lines, int
    }
  }
end

return Treesitter
