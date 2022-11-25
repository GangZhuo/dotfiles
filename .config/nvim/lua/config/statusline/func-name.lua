local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    { fg =  '#48b0bd' },
    'func_name',
    options
  )
end

function M:update_status()
  if not (self.enabled or self.enabled == nil) then
    return ''
  end
  local retval
  local b = require("config.lsp.fname").get_bufinfo()
  if b and b.current_lsp_symbol then
    retval = string.format('%s%s',
               highlight.component_format_highlight(self.color),
               tostring(b.current_lsp_symbol))
  end
  return retval or ''
end

return M
