-- Smart tab labels: show path only when filenames conflict
vim.o.tabline = "%!v:lua.SmartTabline()"

function _G.SmartTabline()
  local s = ""
  local tab_count = vim.fn.tabpagenr("$")

  -- Collect all buffer names
  local bufnames = {}
  for i = 1, tab_count do
    local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local bufname = vim.fn.bufname(bufnr)
    table.insert(bufnames, bufname)
  end

  -- Check for duplicate filenames
  local filenames = {}
  local duplicates = {}
  for _, fullpath in ipairs(bufnames) do
    local filename = vim.fn.fnamemodify(fullpath, ":t")
    if filename ~= "" then
      if filenames[filename] then
        duplicates[filename] = true
      end
      filenames[filename] = true
    end
  end

  -- Build tabline
  for i = 1, tab_count do
    local bufnr = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
    local bufname = vim.fn.bufname(bufnr)
    local filename = vim.fn.fnamemodify(bufname, ":t")

    -- Highlight current tab
    if i == vim.fn.tabpagenr() then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end

    -- Tab number
    s = s .. " " .. i .. " "

    -- Show path if duplicate filename exists
    if filename ~= "" and duplicates[filename] then
      s = s .. vim.fn.fnamemodify(bufname, ":~:.")
    else
      s = s .. (filename ~= "" and filename or "[No Name]")
    end

    s = s .. " "
  end

  s = s .. "%#TabLineFill#"
  return s
end
