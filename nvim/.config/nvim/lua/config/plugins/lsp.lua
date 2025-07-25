-- Add any extra language-servers in here -- can add settings too
local servers = {
  lua_ls = {},
  basedpyright = {
    settings = {
      basedpyright = {
        typeCheckingMode = "basic",
        reportMissingTypeStubs = false,
      }
    }
  },
  terraformls = {},
}

return {
  {
    "mason-org/mason.nvim",
    opts = {}
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_enable = vim.tbl_keys(servers),
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = false
      })
    end

  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      -- Completion Plugin
      { 'saghen/blink.cmp' },
    },
    config = function()
      -- Configure diagnostic signs and virtual text
      -- TODO: Check how Kickstart-Nvim does this
      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.HINT]  = "",
            [vim.diagnostic.severity.INFO]  = "",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require("lspconfig")


      for name, opts in pairs(servers) do
        opts.capabilities = capabilities
        lspconfig[name].setup(opts)
      end


      -- Formatting on save
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
              end,
            })
          end
        end,
      })
    end
  }
}
