return {
  {
    "saghen/blink.cmp",
    dependencies = { "onsails/lspkind.nvim", "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    version = "v0.*",

    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
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

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            fallbacks = { "snippets", "buffer" },
          },
          snippets = {
            min_keyword_length = 1,
            score_offset = -1,
            opts = {
              friendly_snippets = true, -- default
              extended_filetypes = {
                markdown = { "jekyll" },
                sh = { "shelldoc" },
                python = { "python" },
                c = { "c", "cdoc" },
                cpp = { "unreal", "cpp", "cppdoc" },
                vue = { "html", "script", "nuxt-html", "nuxt-script", "vue", "style" },
                cs = { "csharp", "unity" },
                zig = { "zig" },
                typescript = { "typescript" },
              },
            },
          },
          path = { opts = { get_cwd = vim.uv.cwd } },
          buffer = {
            max_items = 4,
            min_keyword_length = 5, -- slightly less noisy
            score_offset = -4,
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

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          window = { border = vim.g.borderStyle },
        },

        menu = {
          border = vim.g.borderStyle,

          draw = (function()
            local function trunc(s, max)
              if not s or s == "" then
                return ""
              end
              s = tostring(s)
              if #s <= max then
                return s
              end
              return s:sub(1, max - 1) .. "…"
            end

            local function resolve_source(ctx)
              local source = ctx.item.source_id
              local client = ctx.item.client_id

              if client then
                local client_obj = vim.lsp.get_client_by_id(client)
                if client_obj and client_obj.name == "emmet_language_server" then
                  source = "emmet"
                end
              end

              return source
            end

            local source_badges = {
              lsp = "LSP",
              snippets = "SNIP",
              buffer = "BUF",
              path = "PATH",
              emmet = "EMMET",
            }

            local source_icons = {
              snippets = "󰩫",
              buffer = "󰦨",
              emmet = "",
              path = "",
              lsp = "󰘦",
            }

            return {
              -- If you want the menu to have more “columns”, you do it via components.
              -- The order below is left→right.
              components = {
                kind_icon = {
                  text = function(ctx)
                    local src = resolve_source(ctx)
                    return source_icons[src] or ctx.kind_icon
                  end,
                },

                label = {
                  text = function(ctx)
                    return trunc(ctx.label, 42)
                  end,
                },

                -- Shows function signature / type / snippet detail when available
                detail = {
                  text = function(ctx)
                    -- Blink items typically expose `detail` (LSP CompletionItem.detail)
                    local d = ctx.item.detail or ""
                    if d == "" then
                      return ""
                    end
                    return "  " .. trunc(d, 32)
                  end,
                },

                -- Right-side source badge so you instantly know where it came from
                source = {
                  text = function(ctx)
                    local src = resolve_source(ctx)
                    local badge = source_badges[src] or (src and src:upper() or "")
                    if badge == "" then
                      return ""
                    end
                    return "  [" .. badge .. "]"
                  end,
                },
              },
            }
          end)(),
        },
      },
    },
  },
}
