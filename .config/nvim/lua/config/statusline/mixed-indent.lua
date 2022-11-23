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
  local space_indent_count = vim.b.space_indent_count or 0
  local space_indent_first_line = vim.b.space_indent_first_line or 0
  local tab_indent_count = vim.b.tab_indent_count or 0
  local tab_indent_first_line = vim.b.tab_indent_first_line or 0
  if space_indent_count > 0 and tab_indent_count > 0 then
    retval = string.format('%sMI:SPACE:%d(#%d) MI:TAB:%d(#%d)',
               highlight.component_format_highlight(self.color),
               space_indent_first_line,
               space_indent_count,
               tab_indent_first_line,
               tab_indent_count)
  end
  return retval or ''
end

return M
