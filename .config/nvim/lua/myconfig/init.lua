local utils = require("myconfig.utils")

-- check version
local expected_ver = "0.9.0"
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
require("myconfig.autocmds")
require("myconfig.usercmds")
require("myconfig.mappings")
require("myconfig.plugins")

require("myconfig.colorschemes").set_colorscheme("kanagawa")
