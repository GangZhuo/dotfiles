local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    'WarningMsg',
    'func_name',
    options
  )
end

function M:update_status()
  local retval
  local b = require("trailing-whitespace").get_bufinfo()
  if b and b.tw and b.tw > 0 then
    retval = string.format('%sTW:%d',
               highlight.component_format_highlight(self.color),
               b.tw)
  end
  return retval or ''
end

return M
