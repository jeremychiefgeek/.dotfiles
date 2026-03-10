return {
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      -- makes sure mason-lspconfig actually installs these LSPs
      ensure_installed = { "lua_ls", "vtsls", "vue_ls" },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    lazy = false,
    opts = {
      servers = {
        roslyn = {},
      },
    },
    config = function()
      -- capabilities (blink.cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.get_lsp_capabilities then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      local mason_root = vim.fn.stdpath("data") .. "/mason"
      local vue_ts_plugin_location = mason_root .. "/packages/vue-language-server/node_modules/@vue/language-server"
      local tsdk = mason_root .. "/packages/typescript-language-server/node_modules/typescript/lib"

      -- vtsls (TypeScript/JS) + Vue TS plugin so Vue SFCs work properly
      vim.lsp.config("vtsls", {
        capabilities = capabilities,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vue_ts_plugin_location,
                  languages = { "vue" },
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                },
              },
            },
          },
        },
      })

      -- Roslyn (C#)
      vim.lsp.config("roslyn", {
        on_attach = function()
          print("This will run when the server attaches!")
        end,
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
          },
        },
      })

      -- vue-language-server (Volar)
      vim.lsp.config("vue_ls", {
        capabilities = capabilities,
        init_options = {
          typescript = {
            tsdk = tsdk,
          },
        },
      })

      -- lua-language-server
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
      })

      -- enable servers
      vim.lsp.enable({ "vtsls", "vue_ls", "lua_ls", "roslyn" })

      -- keymaps
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set("n", "<leader>gf", function()
        vim.lsp.buf.format({ async = true })
      end, {})
      vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, {})
    end,
  },
}
