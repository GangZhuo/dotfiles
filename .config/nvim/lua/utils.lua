local fn = vim.fn

local M = {}

function M.executable(name)
  if fn.executable(name) > 0 then
    return true
  end

  return false
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
  local status, error = pcall(vim.cmd, "packadd " .. name)
  if status ~= 0 then
    vim.notify(tostring(error), vim.log.levels.ERROR, { title = "add pack" })
  end
  return status
end

function M.load_config(name)
  local path = string.format("%s/lua/config/%s.vim", vim.fn.stdpath("config"), name)
  local source_cmd = "source " .. path
  local status, error = pcall(vim.cmd, source_cmd)
  if status ~= 0 then
    vim.notify(tostring(error), vim.log.levels.ERROR, { title = "load config" })
  end
  return status
end

return M
