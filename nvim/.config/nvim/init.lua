-- Custom Neovim Config by Juanse

require("config.lazy")

-- Source file
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")

-- Make clipboard share same memory
vim.o.clipboard = "unnamedplus"

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
