local fn = vim.fn
local api = vim.api

local utils = require('utils')

-- Inspect something
function _G.inspect(item)
  vim.print(item)
end

local function zstr(s)
  return s == nil or s == ''
end

------------------------------------------------------------------------
--                          custom variables                          --
------------------------------------------------------------------------
vim.g.is_win = (utils.has("win32") or utils.has("win64")) and true or false
vim.g.is_linux = (utils.has("unix") and (not utils.has("macunix"))) and true or false
vim.g.is_mac  = utils.has("macunix") and true or false

vim.g.logging_level = "info"

-- Set http(s)_proxy when running on windows os
if vim.g.is_win then
  local proxy = "http://127.0.0.1:1081/"
  if zstr(vim.env.http_proxy) then
    vim.env.http_proxy = proxy
  end
  if zstr(vim.env.https_proxy) then
    vim.env.https_proxy = proxy
  end
end

------------------------------------------------------------------------
--                         builtin variables                          --
------------------------------------------------------------------------
vim.g.loaded_perl_provider = 0  -- Disable perl provider
vim.g.loaded_ruby_provider = 0  -- Disable ruby provider
vim.g.loaded_node_provider = 0  -- Disable node provider
vim.g.did_install_default_menus = 1  -- do not load menu

if utils.executable('python3') then
  if vim.g.is_win then
    vim.g.python3_host_prog = fn.substitute(fn.exepath("python3"), ".exe$", '', 'g')
  else
    vim.g.python3_host_prog = fn.exepath("python3")
  end
elseif utils.executable('python') then
  local x = utils.exec_cmd('python --version')
  local a = utils.split(x, ' ')
  local b = utils.split(a[2], '.')
  local v = tonumber(b[1])
  if v == 3 then
    if vim.g.is_win then
      vim.g.python3_host_prog = fn.substitute(fn.exepath("python"), ".exe$", '', 'g')
    else
      vim.g.python3_host_prog = fn.exepath("python")
    end
  else
    api.nvim_err_writeln("Python3 executable not found! You must install Python3 and set its PATH correctly!")
    return
  end
else
  api.nvim_err_writeln("Python3 executable not found! You must install Python3 and set its PATH correctly!")
  return
end

-- Custom mapping <leader> (see `:h mapleader` for more info)
vim.g.mapleader = ','

-- Enable highlighting for lua HERE doc inside vim script
vim.g.vimsyn_embed = 'l'

-- Use English as main language
vim.cmd [[language en_US.UTF-8]]

-- Disable loading certain plugins

-- Whether to load netrw by default, see https://github.com/bling/dotvim/issues/4
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_liststyle = 3
if vim.g.is_win then
  vim.g.netrw_http_cmd = "curl --ssl-no-revoke -Lo"
end

-- Do not load tohtml.vim
vim.g.loaded_2html_plugin = 1

-- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
-- related to checking files inside compressed files)
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
