local fn = vim.fn
local api = vim.api
local notify = vim.notify
local INFO = vim.log.levels.INFO
local ERROR = vim.log.levels.ERROR
local utils = require("myconfig.utils")

api.nvim_create_user_command(
  'Sudowrite',
  function(opts)
    local filepath = opts.args;
    if utils.zstr(filepath) then
      filepath = fn.expand("%")
    end
    local succ, output = utils.sudo_write(filepath);
    if succ then
      local msg = string.format('"%s" written', filepath)
	  utils.info(msg)
      notify(msg, INFO, { title = "Sudowrite" })
    else
      local msg = string.format('%s', output or 'Sudowrite Failed!')
	  utils.err(msg)
      notify(msg, ERROR, { title = "Sudowrite" })
    end
  end,
  { nargs = '?', desc = 'Write file with privileges' }
)
