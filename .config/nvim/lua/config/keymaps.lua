-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps hererequire
-- require("telescope").extensions.flutter.commands()

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })

-- Flutter keymaps (dart files only)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dart",
  callback = function(ev)
    vim.keymap.set("n", "<leader>cF", "", { buffer = ev.buf, desc = "+Flutter" })

    local map = function(key, cmd, desc)
      vim.keymap.set("n", "<leader>cF" .. key, "<cmd>" .. cmd .. "<cr>", { buffer = ev.buf, desc = desc })
    end

    -- App lifecycle
    map("f", "FlutterRun",     "Run")
    map("d", "FlutterDebug",   "Debug")
    map("r", "FlutterReload",  "Hot Reload")
    map("R", "FlutterRestart", "Restart")
    map("q", "FlutterQuit",    "Quit")
    map("a", "FlutterAttach",  "Attach")
    map("D", "FlutterDetach",  "Detach")

    -- Devices / emulators
    map("v", "FlutterDevices",   "Devices")
    map("e", "FlutterEmulators", "Emulators")

    -- UI tools
    map("o", "FlutterOutlineOpen",   "Outline Open")
    map("O", "FlutterOutlineToggle", "Outline Toggle")
    map("t", "FlutterLogToggle",     "Log Toggle")
    map("T", "FlutterLogClear",      "Log Clear")
    map("i", "FlutterInspectWidget", "Inspect Widget")
    map("V", "FlutterVisualDebug",   "Visual Debug")
    map("b", "FlutterToggleBrightness",     "Toggle Brightness")
    map("x", "FlutterChangeTargetPlatform", "Change Target Platform")

    -- Dev tools
    map("p", "FlutterDevTools",         "Dev Tools")
    map("P", "FlutterDevToolsActivate", "Dev Tools Activate")
    map("u", "FlutterCopyProfilerUrl",  "Copy Profiler URL")
    map("U", "FlutterOpenDevTools",     "Open Dev Tools")

    -- LSP
    map("l", "FlutterLspRestart", "LSP Restart")
    map("s", "FlutterSuper",      "Go to Super")
    map("z", "FlutterReanalyze",  "Reanalyze")
    map("n", "FlutterRename",     "Rename")

    -- Packages
    map("g", "FlutterPubGet",     "Pub Get")
    map("G", "FlutterPubUpgrade", "Pub Upgrade")

    -- FVM
    map("k", "FlutterFvmList", "FVM List")
    map("K", "FlutterFvmUse",  "FVM Use")
  end,
})
