local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    'WarningMsg',
    'mixed_indent',
    options
  )
end

function M:update_status()
  local retval
  local b = require("myconfig.trailing-whitespace").get_bufinfo()
  if b and b.mi and b.mi > 0 then
    retval = string.format('%sMI:%d',
               highlight.component_format_highlight(self.color),
               b.mi)
  end
  return retval or ''
end

return M
