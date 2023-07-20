local utils = require("myconfig.utils")

-- check version
local expected_ver = "0.9.20"
if not utils.is_expect_ver(expected_ver) then
  local msg = string.format(
      "Unsupported nvim version: expect %s, but got %s instead!",
      expected_ver, utils.get_nvim_version())
  utils.err(msg)
  return
end

-- Use English as main language
vim.cmd.language("en_US.UTF-8")

-- Enable lua-loader that byte-compiles and caches lua files
vim.loader.enable()

-- Automatically set http(s)_proxy base on environment variables
utils.set_http_proxy()

require("myconfig.globals")
require("myconfig.options")

--[[
local core_conf_files = {
  "globals.lua", -- some global settings
  "options.vim", -- setting options in nvim
  "autocommands.vim", -- various autocommands
  "usercommands.lua", -- user commands
  "mappings.lua", -- all the user-defined mappings
  "plugins.vim", -- all the plugins installed and their configurations
  "theme.lua", -- set colorscheme
}

-- source all the core config files
for _, name in ipairs(core_conf_files) do
  local path = string.format("%s/core/%s", vim.fn.stdpath("config"), name)
  local source_cmd = "source " .. path
  vim.cmd(source_cmd)
end
--]]

