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

  vim.keymap.set("n", "<leader>cF", "", { desc = "+Flutter" })

  local map = function(key, cmd, desc)
    vim.keymap.set("n", "<leader>cF" .. key, "<cmd>" .. cmd .. "<cr>", { desc = desc })
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
  map("t", "FlutterLogToggle", "Log Toggle")
  map("T", "FlutterLogClear", "Log Clear")
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

  -- Toggle between source and test file
  vim.keymap.set("n", "<leader>cFc", function()
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
