local fn = vim.fn

local M = {}

function M.zstr(s)
  return s == nil or s == ""
end

function M._echo_multiline(msg)
  for _, s in ipairs(vim.fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''") .. "'")
  end
end

function M.info(msg)
  vim.cmd("echohl Directory")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.warn(msg)
  vim.cmd("echohl WarningMsg")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.err(msg)
  vim.cmd("echohl ErrorMsg")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.executable(name)
  if fn.executable(name) > 0 then
    return true
  end

  return false
end

function M.exec_cmd(cmd)
  local handle = io.popen(cmd)
  if handle ~= nil then
    local result = handle:read("*a")
    handle:close()
	return result
  end
  return nil
end

--- check whether a feature exists in Nvim
--- @feat: string
---   the feature name, like `nvim-0.7` or `unix`.
--- return: bool
M.has = function(feat)
  if fn.has(feat) == 1 then
    return true
  end

  return false
end

--- Create a dir if it does not exist
function M.may_create_dir(dir)
  local res = fn.isdirectory(dir)

  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

function M.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function M.get_nvim_version()
  local actual_ver = vim.version()

  local nvim_ver_str = string.format("%d.%d.%d", actual_ver.major, actual_ver.minor, actual_ver.patch)
  return nvim_ver_str
end

function M.is_expect_ver(expected_ver)
  local a = M.split(expected_ver, ".")
  local actual_ver = vim.version()
  local b = { actual_ver.major, actual_ver.minor, actual_ver.patch }
  for i,v in ipairs(a) do
    if tonumber(v) > b[i] then
      return false
    end
  end
  return true
end

--- Generate random integers in the range [Low, High], inclusive,
--- adapted from https://stackoverflow.com/a/12739441/6064933
--- @low: the lower value for this range
--- @high: the upper value for this range
function M.rand_int(low, high)
  -- Use lua to generate random int, see also: https://stackoverflow.com/a/20157671/6064933
  math.randomseed(os.time())

  return math.random(low, high)
end

--- Select a random element from a sequence/list.
--- @seq: the sequence to choose an element
function M.rand_element(seq)
  local idx = M.rand_int(1, #seq)

  return seq[idx]
end

function M.add_pack(name)
  local status = pcall(vim.cmd, "packadd " .. name)
  return status
end

function M.load_config(name)
  local path = string.format("%s/lua/config/%s.vim", vim.fn.stdpath("config"), name)
  local source_cmd = "source " .. path
  local status = pcall(vim.cmd, source_cmd)
  return status
end

M.sudo_exec = function(cmd)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret("Password: ")
  vim.fn.inputrestore()
  if M.zstr(password) then
    return false, "Invalid password, sudo aborted"
  end
  local output = vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    return false, output
  end
  return true, output
end

M.sudo_write = function(filepath, tmpfile)
  if M.zstr(filepath) then filepath = vim.fn.expand("%") end
  if M.zstr(filepath) then
    return false, "No file name"
  end
  if M.zstr(tmpfile) then tmpfile = vim.fn.tempname() end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    vim.fn.shellescape(tmpfile),
    vim.fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  local succ, output = M.sudo_exec(cmd)
  if succ then
    vim.cmd("e!")
  end
  vim.fn.delete(tmpfile)
  return succ, output
end

return M
