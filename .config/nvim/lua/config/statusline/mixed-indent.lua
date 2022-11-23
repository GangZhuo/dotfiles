local fn = vim.fn

local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

local mixed_indent = function()
  if not vim.o.modifiable then
    return ''
  end

  local space_pat = [[\v^ +]]
  local tab_pat = [[\v^\t+]]
  local space_indent = fn.search(space_pat, "nwc")
  local tab_indent = fn.search(tab_pat, "nwc")
  local mixed = (space_indent > 0 and tab_indent > 0)
  local mixed_same_line
  if not mixed then
    mixed_same_line = fn.search([[\v^(\t+ | +\t)]], "nwc")
    mixed = mixed_same_line > 0
  end
  if not mixed then
    return ''
  end
  if mixed_same_line ~= nil and mixed_same_line > 0 then
    return 'MI:' .. mixed_same_line
  end
  local space_indent_cnt = fn.searchcount({ pattern = space_pat, max_count = 1e3 }).total
  local tab_indent_cnt = fn.searchcount({ pattern = tab_pat, max_count = 1e3 }).total
  if space_indent_cnt > tab_indent_cnt then
    return 'MI:' .. tab_indent
  else
    return 'MI:' .. space_indent
  end
end

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    'WarningMsg',
    'func_name',
    self.options
  )
end

function M.setup(opts)
  return self
end

function M:update_status()
  if not (self.enabled or self.enabled == nil) then
    return ''
  end
  local retval
  local s = mixed_indent()
  if s then
    retval = string.format('%s%s',
               highlight.component_format_highlight(self.color),
               s)
  end
  return retval or ''
end

return M
