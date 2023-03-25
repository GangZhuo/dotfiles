-- Check trailing space and mixed indent

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local diagnostic = vim.diagnostic

local config = {
  enable = true,
  skip_large_file = 5000,
  tw = {
    enable = true,
    message = "Trailing Whitespace",
  },
  mi = {
    enable = true,
    message = "Mixed Indent",
  },
  colors = { bg = "red", fg = "red", },
  excluded_ft = { "alpha", "git", "floggraph", "dashboard", },
  severity = diagnostic.severity.HINT,
  source = "[TW]",
  -- Is it a comment at given [row, col] position
  is_comment = function (row, col)
    if vim.treesitter then
      local captures = vim.treesitter.get_captures_at_pos(0, row, col)
      for _,item in ipairs(captures) do
        if item.capture == "comment" or item.capture == "string" then
          return true
        end
      end
    end
    return false
  end
}

local hl_ns = api.nvim_create_namespace("TrailingWhitespaceHighlightNS")
local diag_ns = api.nvim_create_namespace("TrailingWhitespaceDiagnosticNS")
local timer = uv.new_timer()
local scheduled = false
local bufinfo = {}

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

local buffer_enabled = function()
  return bo("modifiable")
     --and bo("modified")
     and bo("buflisted")
     and bo("bufhidden") == ""
     and bo("buftype") == ""
     and not contains(config.excluded_ft, bo("filetype"))
end

local get_bufinfo = function (bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local b = bufinfo[bufnr]
  if not b then
    b = {
      enable = buffer_enabled(),
      bufnr = bufnr,
      bufname = fn.bufname(),
      changedtick = 0,
      running = false,
      last_update = nil,
    }
    bufinfo[bufnr] = b
  end
  return b
end

local strip = function(line_start, line_end)
  if not buffer_enabled() then return end
  if line_start == nil then line_start = 0 end
  if line_end == nil then line_end = fn.line('$') end
  local cmd = string.format([[
    let s:save = winsaveview()
    keeppatterns %d,%ds/\v\s+$//e
    call winrestview(s:save)
  ]], line_start, line_end)
  vim.cmd(cmd)
end

local update = function(b)
  b = b or get_bufinfo()
  api.nvim_buf_clear_namespace(0, hl_ns, 0, -1)
  diagnostic.reset(diag_ns, 0)
  local tw = 0
  local space = {}
  local tab = {}
  local diags = {}
  local set = function (line, col_start, col_end, msg)
      api.nvim_buf_add_highlight(0, hl_ns, "TrailingWhitespace",
        line, col_start, col_end)
      table.insert(diags, {
        lnum = line,
        end_lnum = line,
        col = col_start,
        end_col = col_end,
        severity = config.severity,
        message = msg,
        source = config.source,
      })
  end
  for i = 1, fn.line('$') do
    local linetext = fn.getline(i)

    -- Checking trailing whitespace
    if config.tw.enable then
      local idx = fn.match(linetext, [[\v\s+$]])
      if idx ~= -1 then
        tw = tw + 1
        set(i - 1, idx, -1, config.tw.message)
      end
    end

    -- Checking mixed-indent
    if config.mi.enable then
      local ch = string.sub(linetext, 1, 1)
      if ch == " " or ch == "\t" then
        local s = string.match(linetext, "^%s+")
        if not config.is_comment(i - 1, #s) then
          if ch == " " then
            table.insert(space, i)
          elseif ch == "\t" then
            table.insert(tab, i)
          end
        end
      end
    end
  end

  b.tw = tw

  -- Found mixed-indent
  if #space > 0 and #tab > 0 then
    local lines
    if #space <= #tab then
      lines = space
    else
      lines = tab
    end
    for _,i in ipairs(lines) do
      local linetext = fn.getline(i)
      local s = string.match(linetext, "^%s+")
      set(i - 1, 0, #s, config.mi.message)
    end
    b.mi = #lines
  else
    b.mi = 0
  end

  if #diags > 0 then
    diagnostic.set(diag_ns, 0, diags, {
      underline = false,
      virtual_text = false,
    })
  end
  b.last_update = uv.now()
end

local callback = vim.schedule_wrap(function()
  if not scheduled then return end
  scheduled = false
  local b = get_bufinfo()
  if not b.enable then return end
  local changedtick = api.nvim_buf_get_changedtick(0)
  if b.changedtick == changedtick then return end
  if b.running then return end
  b.running = true
  b.changedtick = changedtick
  update(b)
  b.running = false
end)

local set_autocmds = function ()
  local augroup = api.nvim_create_augroup("trailing_whitespace_augroup", { clear = true })
  api.nvim_create_autocmd({ "FileType", "InsertLeave", "TextChanged" }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      if not config.enable then return end
      local b = get_bufinfo()
      if not b.enable then return end
      if config.skip_large_file and fn.line('$') > config.skip_large_file then
        return
      end
      scheduled = true
      api.nvim_set_hl(hl_ns, "TrailingWhitespace", config.colors)
      diagnostic.enable(0, diag_ns)
    end,
  })
  api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      if not config.enable then return end
      local b = get_bufinfo()
      if not b.enable then return end
      scheduled = false
      api.nvim_set_hl(hl_ns, "TrailingWhitespace", {})
      diagnostic.disable(0, diag_ns)
    end,
  })
  api.nvim_create_autocmd({ "BufDelete" }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      scheduled = false
      local bufnr = api.nvim_get_current_buf()
      bufinfo[bufnr] = nil
    end,
  })
end

local setup = function(user_config)
  config = vim.tbl_deep_extend('keep', user_config or {}, config)
  api.nvim_set_hl(hl_ns, "TrailingWhitespace", config.colors)
  api.nvim_set_hl_ns(hl_ns)
  if not config.enable then
    uv.timer_stop(timer)
    return
  end
  set_autocmds()
  uv.timer_start(timer, 100, 100, callback)
  scheduled = true
end

return {
  config = config,
  bufinfo = bufinfo,
  setup = setup,
  update = update,
  strip = strip,
  get_bufinfo = get_bufinfo,
}
