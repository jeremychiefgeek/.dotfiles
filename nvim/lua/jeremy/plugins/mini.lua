return {
  {
    "echasnovski/mini.files",
    version = false,
    config = function()
      local mf = require("mini.files")
      mf.setup()

      -- Open mini.files in the directory of the current file
      vim.keymap.set("n", "-", function()
        local path = vim.fn.expand("%:p:h")
        -- Guard against mini.files' own virtual buffers (minifiles://)
        if path == "" or path:match("^minifiles://") then
          path = vim.fn.getcwd()
        end
        mf.open(path)
      end)

      -- Inside mini.files: <C-v> vsplit, <C-x> hsplit
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MiniFilesBufferCreate",
        callback = function(ev)
          local buf = ev.data.buf_id

          local function open_split(cmd)
            local entry = mf.get_fs_entry()
            if not entry or entry.fs_type ~= "file" then return end
            mf.close()
            vim.cmd(cmd .. " " .. vim.fn.fnameescape(entry.path))
          end

          vim.keymap.set("n", "<C-v>", function() open_split("vsplit") end, { buffer = buf })
          vim.keymap.set("n", "<C-x>", function() open_split("split")  end, { buffer = buf })
        end,
      })

      -- When mini.files creates a new file, apply header/source templates.
      -- mini.files touches the file on disk immediately, so BufNewFile never
      -- fires when we open it. Instead we write the template directly here,
      -- then open the file in a normal (non-winfixbuf) window.
      vim.api.nvim_create_autocmd("User", {
        pattern  = "MiniFilesActionCreate",
        callback = function(ev)
          local path = ev.data.to
          if not path then return end
          vim.schedule(function()
            -- Write template lines directly to disk before opening
            local ac = require("jeremy.config.autocmds")
            local lines = nil
            if path:match("%.[hH]$") or path:match("%.hin$") then
              lines = ac._header_lines(path)
            elseif path:match("%.[cC]$") or path:match("%.cpp$") or path:match("%.cin$") then
              lines = ac._source_lines(path)
            end

            if lines then
              local f = io.open(path, "w")
              if f then
                f:write(table.concat(lines, "\n") .. "\n")
                f:close()
              end
            end

            -- Now open in a normal window
            mf.close()
            local target_win = nil
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if not vim.wo[win].winfixbuf then
                target_win = win
                break
              end
            end
            if target_win then
              vim.api.nvim_set_current_win(target_win)
            end
            vim.cmd("edit " .. vim.fn.fnameescape(path))
          end)
        end,
      })
    end,
  },
}
