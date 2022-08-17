local Bufferline = {}

Bufferline.config = function()
  local groups = require('bufferline.groups')
  lvim.builtin.bufferline.options.enforce_regular_tabs = true
  lvim.builtin.bufferline.options.always_show_bufferline = true
  lvim.builtin.bufferline.options.groups = {
    items = {
      {
        name = "Docs",
        highlight = { gui = "underline", guisp = "blue" },
        auto_close = true,
        icon = "",
        priority = 1,
        matcher = function(buf)
          return buf.name:match('.md') or buf.name:match('.txt') or buf.name:match('README')
        end,
      },
      {
        name = "Tests",
        highlight = { gui = "underline", guisp = "blue" },
        auto_close = true,
        icon = "",
        priority = 2,
        matcher = function(buf)
          return buf.name:match('%_test') or buf.name:match('%_spec')
        end,
      },
      --groups.builtin.ungrouped,
    },
  }
end

return Bufferline
