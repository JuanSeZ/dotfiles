return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")

      require("mason-nvim-dap").setup({
        ensure_installed = { "python" },
        handlers = {},
      })

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}", -- Runs the currently open file
        },
        {
          type = "python",
          request = "launch",
          name = "Debug Pytest Method",
          module = "pytest",
          args = {
            "${file}::${input:Test method name}",
          },
        },
      }
    end,

    -- Essential keymaps for debugging
    keys = {
      {
        "<Leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<Leader>dr",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<Leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<Leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<Leader>du",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,

    -- Keymaps for UI functionality
    keys = {
      {
        "<Leader>dx",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
      {
        "<Leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Evaluate Expression",
        mode = { "n", "v" },
      },
    },
  },
}
