return {
  "stevearc/oil.nvim",
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<CR>", desc = "Explorer (Oil)" },
  },
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
