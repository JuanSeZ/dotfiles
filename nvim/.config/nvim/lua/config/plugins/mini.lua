return {
  {
    "echasnovski/mini.nvim",
    config = function()
      local statusline = require("mini.statusline")
      -- TODO: Keymaps para hacer bb y bc
      local tabline = require("mini.tabline")
      statusline.setup({ use_icons = true })
      tabline.setup({ use_icons = true })
    end,
  },
}
