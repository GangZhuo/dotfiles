-- Show function name in statusline

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp
local proto = vim.lsp.protocol

local config = {
  enabled = true,
  excluded_ft = { "alpha", "git", "floggraph", "dashboard", },
  scope_kinds = {
    Class = true,
    Function = true,
    Method = true,
    Struct = true,
    Enum = true,
    Interface = true,
    Namespace = true,
    Module = true,
  },
}

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

---Get object path.
---@param root table
---@param paths string[]
---@return any
local _get = function(root, paths)
  local c = root
  for _, path in ipairs(paths) do
    c = c[path]
    if not c then
      return nil
    end
  end
  return c
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
      bufnr = bufnr,
      bufname = fn.bufname(),
      changedtick = 0,
      running = false,
      client = nil,
    }
    bufinfo[bufnr] = b
  end
  return b
end

local is_client_available = function(b)
  if not b.client then
    return false
  end

  -- client is stopped.
  if b.client.is_stopped() then
    return false
  end

  -- client is not attached to current buffer.
  if not lsp.buf_get_clients(b.bufnr)[b.client.id] then
    return false
  end

  -- client has no completion capability.
  if not _get(b.client.server_capabilities, { "documentSymbolProvider" }) then
    return false
  end

  return true;
end

local in_range = function(pos, range)
  local line = pos[1]
  local char = pos[2]
  if line < range.start.line or line > range['end'].line then return false end
  if
    line == range.start.line and char < range.start.character or
    line == range['end'].line and char > range['end'].character
  then
    return false
  end

  return true
end

local find_symbol = function(root, pos)
  if type(root) ~= "table" or #root == 0 then
    return nil
  end
  --for _,v in ipairs(root) do
  --end
  return "fname"
end

local get_symbol = function(b, cur_pos)
  return find_symbol(b.symbols, cur_pos)
end

local mkcallback = function(b, cb)
  return function(_, response)
    b.symbols = response
    cb()
  end
end

local update = function(b, cb)
  b = b or get_bufinfo()
  local params = { textDocument = lsp.util.make_text_document_params() }
  lsp.buf_request(0, 'textDocument/documentSymbol', params, mkcallback(b, cb))
end

local callback = vim.schedule_wrap(function()
  if not scheduled then return end
  local b = get_bufinfo()
  if b.running then return end
  scheduled = false
  if not is_client_available(b) then return end
  if not buffer_enabled() then return end
  local changedtick = api.nvim_buf_get_changedtick(0)
  local cur_pos = api.nvim_win_get_cursor(0)
  if b.changedtick == changedtick then
    b.running = true
    b.current_lsp_symbol = get_symbol(b, cur_pos)
    b.running = false
  else
    b.running = true
    b.changedtick = changedtick
    update(b, function()
      b.current_lsp_symbol = get_symbol(b, cur_pos)
      b.running = false
    end)
  end
end)

local set_autocmds = function ()
  local augroup = api.nvim_create_augroup("lsp_fname_augroup", { clear = true })
  api.nvim_create_autocmd({
      "FileType",
      "InsertLeave",
      "TextChanged",
      "CursorHold",
  }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      if not config.enabled then return end
      scheduled = true
    end,
  })
  api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = "*",
    group = augroup,
    callback = function ()
      if not config.enabled then return end
      scheduled = false
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
  config = vim.tbl_extend('keep', user_config or {}, config)
  set_autocmds()
  uv.timer_start(timer, 100, 100, callback)
end

local attach = function(client, bufnr)
  if not config.enabled then return end
  local b = get_bufinfo(bufnr)
  b.client = client
  scheduled = true
end

return {
  config = config,
  bufinfo = bufinfo,
  attach = attach,
  setup = setup,
  update = update,
  get_bufinfo = get_bufinfo,
}
