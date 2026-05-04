-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-generate jsconfig.json for Vue CLI projects that don't have one
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vue", "javascript", "javascriptreact" },
  callback = function()
    local root = vim.fs.root(0, { "vue.config.js", "vite.config.js", "vite.config.ts", "package.json" })
    if not root then
      return
    end
    -- Skip if tsconfig.json or jsconfig.json already exists
    if vim.uv.fs_stat(root .. "/tsconfig.json") or vim.uv.fs_stat(root .. "/jsconfig.json") then
      return
    end
    -- Only generate for projects that have vue as a dependency
    local pkg_path = root .. "/package.json"
    local pkg_stat = vim.uv.fs_stat(pkg_path)
    if not pkg_stat then
      return
    end
    local pkg = vim.json.decode(table.concat(vim.fn.readfile(pkg_path), "\n"))
    local deps = vim.tbl_extend("force", pkg.dependencies or {}, pkg.devDependencies or {})
    if not deps["vue"] then
      return
    end
    local jsconfig = {
      compilerOptions = {
        baseUrl = ".",
        module = "es2015",
        moduleResolution = "node",
        target = "es2016",
        jsx = "preserve",
        paths = { ["@/*"] = { "src/*" } },
      },
      include = { "src/**/*" },
      exclude = { "node_modules", "dist" },
    }
    local content = vim.json.encode(jsconfig)
    -- Pretty-print the JSON
    local ok, formatted = pcall(vim.fn.system, { "python3", "-m", "json.tool" }, content)
    if ok and vim.v.shell_error == 0 then
      content = formatted
    end
    local f = io.open(root .. "/jsconfig.json", "w")
    if f then
      f:write(content)
      f:close()
      vim.notify("Generated jsconfig.json in " .. root, vim.log.levels.INFO)
    end
  end,
  once = false,
})
