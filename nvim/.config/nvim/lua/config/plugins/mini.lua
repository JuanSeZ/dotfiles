return {
  {
    "echasnovski/mini.nvim",
    config = function()
      local statusline = require("mini.statusline")
      -- TODO: Keymaps para hacer bb y bc
      local tabline = require("mini.tabline")
      local animate = require("mini.animate")
      local indent_scope = require("mini.indentscope")
      statusline.setup({ use_icons = true })
      tabline.setup({ use_icons = true })
      animate.setup({ cursor = { enable = false } })
      indent_scope.setup()
    end,
  },
}
