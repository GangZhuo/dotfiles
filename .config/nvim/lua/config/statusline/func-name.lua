local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

function M:init(options)
  M.super.init(self, options)
  self.color = highlight.create_component_highlight_group(
    { fg =  '#48b0bd' },
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
  local name = vim.b.lsp_current_function
  if name then
    retval = string.format('%s%s',
               highlight.component_format_highlight(self.color),
               tostring(name))
  end
  return retval or ''
end

return M
