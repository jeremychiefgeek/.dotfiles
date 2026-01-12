return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      -- Lock root to current working directory.
      -- If you want “git root”, I can swap this for a git-root resolver.
      local locked_root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")

      local function is_locked_root(path)
        return vim.fn.fnamemodify(path or "", ":p") == locked_root
      end

      return {
        filesystem = {
          hijack_netrw_behavior = "open_current",
          bind_to_cwd = true,

          window = {
            mappings = {
              -- Oil-ish
              ["-"] = "navigate_up_locked",
              ["<bs>"] = "navigate_up_locked",
              ["q"] = "close_window",

              -- Prevent changing the root / jumping above it
              ["C"] = "none", -- (neo-tree default: set_root)
              ["."] = "none", -- (neo-tree default: set_root / set_root_to_node in some setups)
            },
          },

          commands = {
            navigate_up_locked = function(state)
              -- state.path is the directory currently being shown as the filesystem root
              if is_locked_root(state.path) then
                return -- already at locked root; do nothing
              end

              -- call neo-tree's built-in navigate_up
              require("neo-tree.sources.filesystem.commands").navigate_up(state)
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      require("neo-tree").setup(opts)

      -- Open neo-tree in the current window like Oil
      vim.keymap.set("n", "-", function()
        -- Ensure the tree roots at the locked root (cwd) and reveals current file
        vim.cmd("Neotree position=current reveal")
      end, { desc = "Explorer (neo-tree, locked root)" })
    end,
  },
}
