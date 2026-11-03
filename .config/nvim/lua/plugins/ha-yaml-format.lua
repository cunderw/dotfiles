-- Format the YAML files Home Assistant's config API owns (automations.yaml,
-- scripts.yaml, scenes.yaml in ~/home-assistant) exactly the way HA writes
-- them, so a hand edit and a later save from the HA UI/API don't fight over
-- indentation and quoting. Uses PyYAML 6.0.3, the version HA 2026.10 pins
-- (annotatedyaml 1.0.2), via uv so nothing is installed globally.
-- Every other YAML file keeps the existing chain (prettier with a config,
-- otherwise yamlls).

local ha_root = vim.fs.normalize("~/home-assistant")
local ha_owned = { ["automations.yaml"] = true, ["scripts.yaml"] = true, ["scenes.yaml"] = true }
local script = vim.fn.stdpath("config") .. "/scripts/ha_yaml_format.py"

return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.ha_yaml = {
        command = "uv",
        args = { "run", "-q", "--no-project", "--with", "pyyaml==6.0.3", "python3", "-I", script },
        stdin = true,
        condition = function(_, ctx)
          local path = vim.fs.normalize(ctx.filename)
          return ha_owned[vim.fs.basename(path)] == true and vim.fs.dirname(path) == ha_root
        end,
      }

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local yaml = opts.formatters_by_ft.yaml or {}
      table.insert(yaml, 1, "ha_yaml")
      yaml.stop_after_first = true
      opts.formatters_by_ft.yaml = yaml
    end,
  },
}
