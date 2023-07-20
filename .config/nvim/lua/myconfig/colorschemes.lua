--- This module will load a random colorscheme on nvim startup process.

local utils = require("myconfig.utils")

local M = {}

-- all colorschemes that used by M.next() function
M.colorschemes = {}

-- current selected colorscheme
M.colorscheme = nil

-- Colorscheme to its directory name mapping, because colorscheme
-- repo name is not necessarily the same as the colorscheme name itself.
M.colorscheme2dir = {
  sonokai = "sonokai",
  tokyonight = "tokyonight.nvim",
  ["tokyonight-night"] = "tokyonight.nvim",
  ["tokyonight-storm"] = "tokyonight.nvim",
  ["tokyonight-day"]   = "tokyonight.nvim",
  ["tokyonight-moon"]  = "tokyonight.nvim",
}

for k,_ in pairs(M.colorscheme2dir) do
  table.insert(M.colorschemes, k)
end

M.sonokai = function()
  vim.g.sonokai_enable_italic = 1
  vim.g.sonokai_better_performance = 1

  vim.cmd([[colorscheme sonokai]])
end

M.set_colorscheme = function(colorscheme)
  if not vim.tbl_contains(vim.tbl_keys(M.colorscheme2dir), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
    return false
  end

  -- Load the colorscheme, because all the colorschemes are
  -- declared as opt plugins, so the colorscheme isn't loaded yet.
  local status = utils.add_pack(M.colorscheme2dir[colorscheme])

  if not status then
    local msg = string.format(
        "Colorscheme %s is not installed. Run PackerSync to install.",
        colorscheme)
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
    return false
  end

  -- Load the colorscheme and its settings
  local f = M[colorscheme]
  if type(f) == "function" then
    f()
  else
    vim.cmd("colorscheme "..colorscheme)
  end

  M.colorscheme = colorscheme

  return true
end

M.prev = function()
  local prev
  for i,v in ipairs(M.colorschemes) do
    if v == M.colorscheme then
      prev = i - 1
      break
    end
  end
  if prev == nil or prev == 0 then
    prev = #M.colorschemes
  end
  local colorscheme = M.colorschemes[prev]
  if M.set_colorscheme(colorscheme) then
    vim.notify(string.format("Colorscheme changed to \"%s\".", colorscheme),
        vim.log.levels.NOTICE, { title = "nvim-config" })
  end
end

M.next = function()
  local next
  for i,v in ipairs(M.colorschemes) do
    if v == M.colorscheme then
      next = i + 1
      break
    end
  end
  if next == nil or next > #M.colorschemes then
    next = 1
  end
  local colorscheme = M.colorschemes[next]
  if M.set_colorscheme(colorscheme) then
    vim.notify(string.format("Colorscheme changed to \"%s\".", colorscheme),
        vim.log.levels.NOTICE, { title = "nvim-config" })
  end
end

--- Use a random colorscheme from the pre-defined list of colorschemes.
M.rand_colorscheme = function()
  local colorscheme = utils.rand_element(vim.tbl_keys(M.colorscheme2dir))
  M.set_colorscheme(colorscheme)
end

return M
