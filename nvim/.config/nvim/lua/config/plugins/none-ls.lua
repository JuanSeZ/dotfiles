return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- NOTE: Check lsp.lua to not have duplicated formatters - Null_ls is to tools that have their one cli and not a lsp
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.pylint,
          -- null_ls.builtins.completion.spell,
        },
      })
    end
  }
}
