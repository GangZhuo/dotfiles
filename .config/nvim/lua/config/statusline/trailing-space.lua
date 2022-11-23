local fn = vim.fn

local highlight = require('lualine.highlight')
local M = require('lualine.component'):extend()

local trailing_space = function ()
  if not vim.o.modifiable then
    return ''
  end

  local line_num = nil

  for i = 1, fn.line('$') do
    local linetext = fn.getline(i)
    -- To prevent invalid escape error, we wrap the regex string with `[[]]`.
    local idx = fn.match(linetext, [[\v\s+$]])
    if idx ~= -1 then
      line_num = i
      break
    end
  end

  return line_num or 0
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
  local line_num = trailing_space()
  if line_num > 0 then
    retval = string.format('%s[%d]trailing',
               highlight.component_format_highlight(self.color),
               line_num)
  end
  return retval or ''
end

return M
