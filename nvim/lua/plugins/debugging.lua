return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "stylua",
        "clangd",
        "clang-format",
        "prettier",
        "vue-language-server",
        "typescript-language-server",
        "vtsls",
        "zls",
        "ols",
        "roslyn",
        "csharpier",
        "pyright",
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local mason_dap = require("mason-nvim-dap")
      local dap = require("dap")
      local ui = require("dapui")
      local dap_virtual_text = require("nvim-dap-virtual-text")

      -- Dap Virtual Text
      dap_virtual_text.setup()

      mason_dap.setup({
        ensure_installed = {
          "codelldb",
          "coreclr",
          "python",
        },
        automatic_installation = true,
        handlers = {},
      })
      -- Dap UI
      ui.setup()

      vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
