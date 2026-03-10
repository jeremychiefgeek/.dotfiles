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
      local dap = require("dap")
      local dapui = require("dapui")

      -- Virtual text (inline values) - tasteful defaults
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        commented = true,
        virt_text_pos = "eol", -- "eol" | "inline"
        all_frames = false,
        virt_lines = false,
      })

      -- Install & wire adapters via mason
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "coreclr", "python" },
        automatic_installation = true,
        handlers = {},
      })

      -- Better signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapLogPoint", { text = "▶", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "➜", texthl = "DiagnosticOk" })

      -- DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          -- Use the same muscle memory everywhere
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          -- Left sidebar: scopes + stacks + watches
          {
            elements = {
              { id = "scopes", size = 0.55 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.20 },
            },
            size = 48,
            position = "left",
          },
          -- Bottom: repl + console
          {
            elements = {
              { id = "repl", size = 0.55 },
              { id = "console", size = 0.45 },
            },
            size = 12,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
            disconnect = "",
          },
        },
        floating = {
          max_height = 0.9,
          max_width = 0.9,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
        windows = { indent = 1 },
        render = { max_type_length = 60 },
      })

      -- Auto open/close UI (and don’t steal your layout after exit)
      dap.listeners.before.attach.dapui = function()
        dapui.open({ reset = true })
      end
      dap.listeners.before.launch.dapui = function()
        dapui.open({ reset = true })
      end
      dap.listeners.before.event_terminated.dapui = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui = function()
        dapui.close()
      end

      -- Keymaps (minimal + useful)
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end

      map("<F5>", dap.continue, "DAP: Continue")
      map("<F10>", dap.step_over, "DAP: Step over")
      map("<F11>", dap.step_into, "DAP: Step into")
      map("<F12>", dap.step_out, "DAP: Step out")
      map("<leader>db", dap.toggle_breakpoint, "DAP: Toggle breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "DAP: Conditional breakpoint")
      map("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, "DAP: Log point")
      map("<leader>dr", dap.repl.toggle, "DAP: Toggle REPL")
      map("<leader>du", dapui.toggle, "DAP: Toggle UI")
      map("<leader>de", dapui.eval, "DAP: Eval (cursor)")

      -- Nice: hover-eval in a rounded float
      map("<leader>dh", function()
        require("dap.ui.widgets").hover()
      end, "DAP: Hover widgets")
    end,
  },
}
