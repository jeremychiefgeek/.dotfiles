return {
  {
    "saghen/blink.cmp",
    dependencies = { "onsails/lspkind.nvim" },
    event = "InsertEnter",
    version = "v0.*", -- prebuilt binaries

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      appearance = {
        -- use nvim-cmp highlight groups as fallback
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",

        -- your custom icons
        kind_icons = {
          Text = "󰊄",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "",
          Field = "󰇽",
          Variable = "󰂡",
          Class = "󰜁",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "󰒕",
          Color = "󰏘",
          Reference = "",
          File = "",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰅲",
        },
      },

      -- NOTE: sources.default is the correct shape
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            fallbacks = { "snippets", "buffer" },
          },
          snippets = {
            min_keyword_length = 1,
            score_offset = -1,
          },
          path = {
            opts = { get_cwd = vim.uv.cwd },
          },
          buffer = {
            max_items = 4,
            min_keyword_length = 4,
            score_offset = -3,
          },
        },
      },

      keymap = {
        ["<D-c>"] = { "show" },
        ["<S-CR>"] = { "hide" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<PageDown>"] = { "scroll_documentation_down" },
        ["<PageUp>"] = { "scroll_documentation_up" },
      },

      -- this replaces your old `windows` block
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = {
            border = vim.g.borderStyle,
          },
        },

        menu = {
          border = vim.g.borderStyle,

          -- ported version of your custom draw logic:
          -- change icon based on source/emmet
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local source = ctx.item.source_id
                  local client = ctx.item.client_id

                  if client then
                    local client_obj = vim.lsp.get_client_by_id(client)
                    if client_obj and client_obj.name == "emmet_language_server" then
                      source = "emmet"
                    end
                  end

                  local sourceIcons = {
                    snippets = "󰩫",
                    buffer = "󰦨",
                    emmet = "",
                  }

                  return sourceIcons[source] or ctx.kind_icon
                end,
              },
            },
          },
        },
      },
    },
  },
}
