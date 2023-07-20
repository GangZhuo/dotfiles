local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    { fg = "black", bg = "#a7c080" },
    'spell',
    options
  )
end

function M:update_status()
  if not (self.enabled or self.enabled == nil) then
    return ''
  end
  local retval
  if vim.o.spell then
    retval = string.format('%s%s',
               highlight.component_format_highlight(self.color),
               'SPELL')
  end
  return retval or ''
end

return M
