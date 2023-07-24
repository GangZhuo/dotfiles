local fn = vim.fn

local M = {}

function M.zstr(s)
  return s == nil or s == ""
end

function M._echo_multiline(msg)
  for _, s in ipairs(fn.split(msg, "\n")) do
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

local join_dic = function(dic, sep)
  local str = ""
  for k,v in pairs(dic) do
      if str:len() == 0 then
        str = string.format("%s:%s", k, v)
      else
        str = str..string.format("%s%s:%s", sep, k, v)
      end
  end
  return str
end

local join_arr = function(dic, sep)
  local str = ""
  for _,v in ipairs(dic) do
      if str:len() == 0 then
        str = v
      else
        str = str..string.format("%s%s", sep, v)
      end
  end
  return str
end

local join = function(f, ...)
  local str = ""
  local args = {...}
  local sep = ","
  if type(args[#args]) == "string" then
    sep = args[#args]
    table.remove(args)
  end
  for _,item in ipairs(args) do
    local tmp = f(item, sep)
    if str:len() == 0 then
      str = tmp
    else
      str = str..string.format("%s%s", sep, tmp)
    end
  end
  return str
end

--- Join Directory
--- e.g.
---  local str = M.join_arr({a=1, b=2},{c=3,d=4},",")
---  str: a:1,b:2,c:3,d:4
function M.join_dic(...)
  return join(join_dic, ...)
end

--- Join array
--- e.g.
---  local str = M.join_arr({"a", "b"},{"c","d"},",")
---  str: a,b,c,d
function M.join_arr(...)
  return join(join_arr, ...)
end

--- Remove element from array
function M.remove(arr, val)
  for i,v in ipairs(arr) do
    if v == val then
      table.remove(arr, i)
    end
  end
  return arr
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

--- Get python3 path
function M.get_python3()
  local prog
  if M.executable('python3') then
    prog = fn.exepath("python3")
  elseif M.executable('python') then
    -- Check version
    local x = M.exec_cmd('python --version')
    local a = M.split(x, ' ')
    local b = M.split(a[2], '.')
    local v = tonumber(b[1]) -- Convert major version to number
    if v == 3 then
      prog = fn.exepath("python")
    end
  end
  if prog and vim.g.is_win then
    prog = fn.substitute(prog, ".exe$", '', 'g')
  end
  return prog
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
  local path = string.format("%s/lua/config/%s.vim", fn.stdpath("config"), name)
  local source_cmd = "source " .. path
  local status = pcall(vim.cmd, source_cmd)
  return status
end

M.sudo_exec = function(cmd)
  fn.inputsave()
  local password = fn.inputsecret("Password: ")
  fn.inputrestore()
  if M.zstr(password) then
    return false, "Invalid password, sudo aborted"
  end
  local output = fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    return false, output
  end
  return true, output
end

M.sudo_write = function(filepath, tmpfile)
  if M.zstr(filepath) then filepath = fn.expand("%") end
  if M.zstr(filepath) then
    return false, "No file name"
  end
  if M.zstr(tmpfile) then tmpfile = fn.tempname() end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    fn.shellescape(tmpfile),
    fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  local succ, output = M.sudo_exec(cmd)
  if succ then
    vim.cmd("e!")
  end
  fn.delete(tmpfile)
  return succ, output
end

-- Set http(s)_proxy
M.set_http_proxy = function (url)
  local env = vim.env

  -- Update anyway if url is not empty
  if not M.zstr(url) then
    -- Remove trailing slash
    url = string.gsub(url, "(.-)/*$", "%1")
    env.http_proxy = url
    env.https_proxy = url
    return true, url
  end

  -- Do not update if proxy is already set
  local need_set = M.zstr(env.http_proxy) or M.zstr(env.https_proxy)
  if not need_set then
    return false
  end

  if M.zstr(env.HPROXY_HOST) or M.zstr(env.HPROXY_PORT) then
    return false
  end

  url = string.format("http://%s:%s", env.HPROXY_HOST, env.HPROXY_PORT)

  if M.zstr(env.http_proxy) then
    env.http_proxy = url
  end

  if M.zstr(env.https_proxy) then
    env.https_proxy = url
  end

  return true, url
end

M.is_lsp_attached = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  local buf_client_num = #vim.tbl_keys(buf_clients)
  return buf_client_num > 0
end

return M
