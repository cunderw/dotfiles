-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps hererequire
-- require("telescope").extensions.flutter.commands()

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })

-- Flutter keymaps (flutter projects only)
local flutter_keymaps_loaded = false

local function setup_flutter_keymaps()
  if vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 0 then
    return
  end
  if flutter_keymaps_loaded then
    return
  end
  flutter_keymaps_loaded = true

  vim.keymap.set("n", "<leader>F", "", { desc = "+Flutter" })

  local map = function(key, cmd, desc)
    vim.keymap.set("n", "<leader>F" .. key, "<cmd>" .. cmd .. "<cr>", { desc = desc })
  end

  -- App lifecycle
  map("f", "FlutterRun", "Run")
  map("d", "FlutterDebug", "Debug")
  map("r", "FlutterReload", "Hot Reload")
  map("R", "FlutterRestart", "Restart")
  map("q", "FlutterQuit", "Quit")
  map("a", "FlutterAttach", "Attach")
  map("D", "FlutterDetach", "Detach")

  -- Devices / emulators
  map("v", "FlutterDevices", "Devices")
  map("e", "FlutterEmulators", "Emulators")

  -- UI tools
  map("o", "FlutterOutlineOpen", "Outline Open")
  map("O", "FlutterOutlineToggle", "Outline Toggle")
  map("i", "FlutterInspectWidget", "Inspect Widget")
  map("V", "FlutterVisualDebug", "Visual Debug")
  map("b", "FlutterToggleBrightness", "Toggle Brightness")
  map("x", "FlutterChangeTargetPlatform", "Change Target Platform")

  -- Dev tools
  map("p", "FlutterDevTools", "Dev Tools")
  map("P", "FlutterDevToolsActivate", "Dev Tools Activate")
  map("u", "FlutterCopyProfilerUrl", "Copy Profiler URL")
  map("U", "FlutterOpenDevTools", "Open Dev Tools")

  -- LSP
  map("l", "FlutterLspRestart", "LSP Restart")
  map("s", "FlutterSuper", "Go to Super")
  map("z", "FlutterReanalyze", "Reanalyze")
  map("n", "FlutterRename", "Rename")

  -- Packages
  map("g", "FlutterPubGet", "Pub Get")
  map("G", "FlutterPubUpgrade", "Pub Upgrade")

  -- FVM
  map("k", "FlutterFvmList", "FVM List")
  map("K", "FlutterFvmUse", "FVM Use")

  -- Bloc / Cubit (flutter-bloc.nvim; require() auto-loads the plugin via lazy)
  vim.keymap.set("n", "<leader>FB", function()
    require("flutter-bloc").create_bloc()
  end, { desc = "Create Bloc" })
  vim.keymap.set("n", "<leader>FC", function()
    require("flutter-bloc").create_cubit()
  end, { desc = "Create Cubit" })

  -- Toggle between source and test file
  vim.keymap.set("n", "<leader>Fc", function()
    local path = vim.fn.expand("%:p")
    local root = vim.fn.getcwd()

    local lib_prefix = root .. "/lib/"
    local test_dirs = { "test", "test/unit_tests", "test/integration_tests" }

    -- Source → test: try each test dir in order
    if path:sub(1, #lib_prefix) == lib_prefix then
      local rel = path:sub(#lib_prefix + 1)
      local base = rel:gsub("%.dart$", "")
      for _, dir in ipairs(test_dirs) do
        local candidate = root .. "/" .. dir .. "/" .. base .. "_test.dart"
        if vim.fn.filereadable(candidate) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(candidate))
          return
        end
      end
      vim.notify("No test counterpart found for: " .. rel, vim.log.levels.WARN)
      return
    end

    -- Test → source: strip any of the test dir prefixes
    for _, dir in ipairs(test_dirs) do
      local prefix = root .. "/" .. dir .. "/"
      if path:sub(1, #prefix) == prefix then
        local rel = path:sub(#prefix + 1)
        local base = rel:gsub("_test%.dart$", "")
        local target = lib_prefix .. base .. ".dart"
        if vim.fn.filereadable(target) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(target))
        else
          vim.notify("Source counterpart not found: " .. target, vim.log.levels.WARN)
        end
        return
      end
    end

    vim.notify("Not in lib/ or a recognised test directory", vim.log.levels.WARN)
  end, { desc = "Go to counterpart (test/source)" })
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = setup_flutter_keymaps,
})

vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    flutter_keymaps_loaded = false
    setup_flutter_keymaps()
  end,
})

-- <C-h/j/k/l> and <M-h/j/k/l> are owned by plugin specs, not this file:
--   inside herdr  -> plugins/herdr-splits.lua
--   outside herdr -> plugins/tmux.lua (vim-tmux-navigator)
-- Both declare them in a lazy `keys` table, which is what stops LazyVim
-- claiming them on VeryLazy. Do not add them here as well.
--
-- The exception is the Herdr app (HC_TERMINAL_ID set, HERDR_ENV not), where
-- neither plugin loads: its smart-nav mod sends these keys here, and at the
-- last split we hand back with out-<dir>. Pane resize has no app command, so
-- <M-H/J/K/L> only resize nvim splits there.
if vim.env.HC_TERMINAL_ID and vim.env.HERDR_ENV ~= "1" then
  local function nav(key, dir)
    vim.keymap.set("n", "<C-" .. key .. ">", function()
      local win = vim.api.nvim_get_current_win()
      vim.cmd("wincmd " .. key)
      if vim.api.nvim_get_current_win() == win then
        vim.system({ "herdr-app", "do", "smart-nav.out-" .. dir })
      end
    end, { desc = "Navigate " .. dir .. " (nvim/herdr-app)" })
  end
  nav("h", "left")
  nav("j", "down")
  nav("k", "up")
  nav("l", "right")

  vim.keymap.set("n", "<M-H>", "<cmd>vertical resize -2<cr>", { desc = "Resize left" })
  vim.keymap.set("n", "<M-J>", "<cmd>resize -2<cr>", { desc = "Resize down" })
  vim.keymap.set("n", "<M-K>", "<cmd>resize +2<cr>", { desc = "Resize up" })
  vim.keymap.set("n", "<M-L>", "<cmd>vertical resize +2<cr>", { desc = "Resize right" })

  -- The my-files mod opens files here, at a socket named after the terminal.
  local server = vim.fn.stdpath("state") .. "/herdr-" .. vim.env.HC_TERMINAL_ID .. ".sock"
  vim.fn.delete(server)
  pcall(vim.fn.serverstart, server)

  local function is_tiled(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end

  local function is_editor(win)
    return is_tiled(win) and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
  end

  -- The window a file belongs in: this one, else any editor window, else the
  -- widest one, so a dashboard is replaced and the file tree is not. Only a
  -- tree on its own gets a split.
  local function open_target()
    local current = vim.api.nvim_get_current_win()
    if is_editor(current) then
      return current
    end
    local wins = vim.tbl_filter(is_tiled, vim.api.nvim_tabpage_list_wins(0))
    local editor = vim.tbl_filter(is_editor, wins)[1]
    if editor then
      return editor
    end
    table.sort(wins, function(a, b)
      return vim.api.nvim_win_get_width(a) > vim.api.nvim_win_get_width(b)
    end)
    if #wins > 1 then
      return wins[1]
    end
  end

  function _G.herdr_open(path, line)
    local win = open_target()
    if win then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd("rightbelow vnew")
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
    if line and line > 0 then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
      vim.cmd("normal! zz")
    end
    return ""
  end
end
