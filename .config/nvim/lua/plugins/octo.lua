return {
  {
    -- Your git remotes use the SSH host alias `github.com-underwoc` (see ~/.ssh/config)
    -- for per-key auth. Octo parses that alias into the repo's host, which breaks the
    -- gh/API calls. ssh_aliases rewrites the alias back to the real host. The key is an
    -- anchored Lua pattern, but octo escapes `-` for you, so write it literally.
    "pwntester/octo.nvim",
    opts = {
      ssh_aliases = { ["github.com-underwoc"] = "github.com" },
    },
  },
}
