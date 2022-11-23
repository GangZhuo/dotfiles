local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    'WarningMsg',
    'func_name',
    self.options
  )
end

function M:update_status()
  local retval
  local line_num = vim.b.trailing_whitespace_line or 0
  if line_num > 0 then
    retval = string.format('%s[%d]trailing',
               highlight.component_format_highlight(self.color),
               line_num)
  end
  return retval or ''
end

return M
