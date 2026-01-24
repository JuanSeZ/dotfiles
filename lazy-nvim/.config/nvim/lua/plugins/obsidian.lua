return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    -- Disable spell checking for files in the zettelkasten vault
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = vim.fn.expand("~") .. "/university/zettelkasten/*",
      callback = function()
        vim.opt_local.spell = false
      end,
    })
  end,
  opts = {
    workspaces = {
      {
        name = "zettelkasten",
        path = "~/university/zettelkasten",
      },
    },

    -- Daily notes configuration
    daily_notes = {
      folder = "notes/dailies",
      date_format = "%Y-%m-%d",
    },

    -- Templates configuration
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    -- Follow URL behavior
    follow_url_func = function(url)
      vim.fn.jobstart({ "open", url })
    end,
  },

  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Note" },
    { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Notes" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Today's Note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's Note" },
    { "<leader>om", "<cmd>ObsidianTomorrow<cr>", desc = "Tomorrow's Note" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Links" },
    { "<leader>oT", "<cmd>ObsidianTemplate<cr>", desc = "Insert Template" },
    {
      "<leader>fo",
      function()
        Snacks.picker.files({ cwd = "~/university/zettelkasten" })
      end,
      desc = "Find Obsidian File",
    },
  },
}
