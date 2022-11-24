-- Check trailing space and mixed indent

local api = vim.api
local fn = vim.fn

-- Create highlight namespace
local hl_ns = api.nvim_create_namespace("TrailingWhitespace")

local timer
local last_update = nil

local M = { }

M.config = {
  enabled = true,
  colors = { bg = "red", fg = "red", },
  excluded_ft = { "alpha", "git", "floggraph", "dashboard", },
  max_interval = 1000,
}

local bo = function(opt_name)
  return api.nvim_buf_get_option(0, opt_name)
end

local contains = function(array, value)
  if type(array) ~= "table" or value == nil then
    return false
  end
  for _,v in ipairs(array) do
    if v == value then
      return true
    end
  end
  return false
end

M.buffer_enabled = function()
  local config = M.config
  return bo("modifiable")
     and bo("buflisted")
     and bo("bufhidden") == ""
     and bo("buftype") == ""
     and not contains(config.excluded_ft, bo("filetype"))
end

M.clear_highlight = function(line_start, line_end)
  if line_start == nil then line_start = 0 end
  if line_end == nil then line_end = -1 end
  api.nvim_buf_clear_namespace(0, hl_ns, line_start, line_end)
end

M.set_highlight = function (line, col_start, col_end)
  api.nvim_buf_add_highlight(0, hl_ns, "TrailingWhitespace",
    line, col_start, col_end)
end

M.strip_tailing_whitespace = function(line_start, line_end)
  if not M.buffer_enabled() then
    return
  end
  if line_start == nil then line_start = 0 end
  if line_end == nil then line_end = fn.line('$') end
  local cmd = string.format([[
    let s:save = winsaveview()
    keeppatterns %d,%ds/\v\s+$//e
    call winrestview(s:save)
  ]], line_start, line_end)
  vim.cmd(cmd)
end

-- Known issues:
--  * When line_start and line_end are not nil,
--    the statusline shown information only these lines
M.update = function(line_start, line_end)
  if not M.buffer_enabled() then
    return
  end
  if line_start == nil then line_start = 0 end
  if line_end == nil then line_end = fn.line('$') end
  M.clear_highlight(line_start, line_end)
  local line_num = nil
  local x = {
    space_line_num = 0,
    first_space_line = 0,
    space_lines = {},
    tab_line_num = 0,
    first_tab_line = 0,
    tab_lines = {},
  }
  for i = line_start, line_end do
    local linetext = fn.getline(i)

    -- Checking trailing whitespace
    local idx = fn.match(linetext, [[\v\s+$]])
    if idx ~= -1 then
      if line_num == nil then
        line_num = i
      end
      M.set_highlight(i - 1, idx, -1)
    end

    -- Checking mixed-indent
    local ch = string.sub(linetext, 1, 1)
    if ch == " " then
        table.insert(x.space_lines, i)
        x.space_line_num = x.space_line_num + 1
        if x.first_space_line == 0 then
            x.first_space_line = i
        end
    elseif ch == "\t" then
        table.insert(x.tab_lines, i)
        x.tab_line_num = x.tab_line_num + 1
        if x.first_tab_line == 0 then
            x.first_tab_line = i
        end
    end
  end

  if line_num == nil then
    vim.b.trailing_whitespace_line = 0
  else
    vim.b.trailing_whitespace_line = line_num
  end

  -- Found mixed-indent
  if x.space_line_num > 0 and x.tab_line_num > 0 then
    vim.b.space_indent_count = x.space_line_num
    vim.b.space_indent_first_line = x.first_space_line
    vim.b.tab_indent_count = x.tab_line_num
    vim.b.tab_indent_first_line = x.first_tab_line

    local lines
    if x.space_line_num <= x.tab_line_num then
      lines = x.space_lines
    else
      lines = x.tab_lines
    end
    for _,v in ipairs(lines) do
      local linetext = fn.getline(v)
      local s = string.match(linetext, "^%s+")
      inspect({v, #s, linetext})
      M.set_highlight(v - 1, 0, #s)
    end
  else
    vim.b.space_indent_count = 0
    vim.b.space_indent_first_line = 0
    vim.b.tab_indent_count = 0
    vim.b.tab_indent_first_line = 0
  end

  last_update = vim.loop.now()
end

M.setup = function(config)
  if type(config) == "table" then
    M.config = vim.tbl_extend('keep', config, M.config)
  end
  if not M.config.enabled then
    return
  end

  api.nvim_set_hl(hl_ns, "TrailingWhitespace", M.config.colors)
  api.nvim_set_hl_ns(hl_ns)

  local augroup = api.nvim_create_augroup("trailing_whitespace_augroup", { clear = true })
  api.nvim_create_autocmd({ "FileType", "InsertLeave", "TextChanged" }, {
    pattern = "*",
    group = augroup,
    callback = function (e)
      if e.event == "TextChanged" then
        local line_start = fn.getpos("'[")[2] - 1
        local line_end = fn.getpos("']")[2]
        M.update(line_start, line_end)
        return
      end
      if timer then
        vim.loop.timer_stop(timer)
        timer = nil
      end
      local now = vim.loop.now()
      if last_update == nil or now - last_update >= M.config.max_interval then
        M.update()
      else
        timer = vim.defer_fn(function()
          M.update()
        end, 100)
      end
    end,
  })
  api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      M.clear_highlight()
    end,
  })
end

return M
