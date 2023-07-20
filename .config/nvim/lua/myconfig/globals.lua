local utils = require("myconfig.utils")

-- Detect OS, and store to global custom variables
vim.g.is_win   = utils.has("win32") or utils.has("win64")
vim.g.is_linux = utils.has("unix") and not utils.has("macunix")
vim.g.is_mac   = utils.has("macunix")

-- Custom mapping <leader> (see `:h mapleader` for more info)
vim.g.mapleader = ','

-- Enable highlighting for lua HERE doc inside vim script
vim.g.vimsyn_embed = 'l'

vim.g.loaded_perl_provider = 0  -- Disable perl provider
vim.g.loaded_ruby_provider = 0  -- Disable ruby provider
vim.g.loaded_node_provider = 0  -- Disable node provider
vim.g.did_install_default_menus = 1  -- do not load menu

-- Disable netrw, see https://github.com/bling/dotvim/issues/4
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_liststyle = 3
if vim.g.is_win then
  vim.g.netrw_http_cmd = "curl --ssl-no-revoke -Lo"
end

-- Do not load tohtml.vim
vim.g.loaded_2html_plugin = 1

-- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim
-- (all these plugins are related to checking files inside compressed files)
vim.g.loaded_zipPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1

-- Do not load the tutor plugin
vim.g.loaded_tutor_mode_plugin = 1

-- Do not use builtin matchit.vim and matchparen.vim since we use vim-matchup
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

-- Disable sql omni completion, it is broken.
vim.g.loaded_sql_completion = 1

-- Check python3
local python3_prog = utils.get_python3()
if python3_prog then
  vim.g.python3_host_prog = python3_prog
else
  utils.err(
      "Python3 executable not found!"..
      " You must install Python3 and set its PATH correctly!")
  return
end


