--- This module will load a random colorscheme on nvim startup process.

local utils = require("utils")

local M = {}

-- all colorschemes that used by M.next() function
M.colorschemes = {}

-- current selected colorscheme
M.colorscheme = nil

-- Colorscheme to its directory name mapping, because colorscheme repo name is not necessarily
-- the same as the colorscheme name itself.
M.colorscheme2dir = {
  onedark = "onedark.nvim",
  edge = "edge",
  sonokai = "sonokai",
  gruvbox_material = "gruvbox-material",
  nord = "nord.nvim",
  everforest = "everforest",
  nightfox = "nightfox.nvim",
  kanagawa = "kanagawa.nvim",
  catppuccin = "catppuccin",
  rose_pine = "rose-pine",
  onedarkpro = "onedarkpro.nvim",
  monokai = "monokai.nvim",
  material = "material.nvim",
}

for k,_ in pairs(M.colorscheme2dir) do
  table.insert(M.colorschemes, k)
end

M.onedark = function()
  vim.cmd([[colorscheme onedark]])
end

M.edge = function()
  vim.g.edge_enable_italic = 1
  vim.g.edge_better_performance = 1

  vim.cmd([[colorscheme edge]])
end

M.sonokai = function()
  vim.g.sonokai_enable_italic = 1
  vim.g.sonokai_better_performance = 1

  vim.cmd([[colorscheme sonokai]])
end

M.gruvbox_material = function()
  -- foreground option can be material, mix, or original
  vim.g.gruvbox_material_foreground = "material"
  --background option can be hard, medium, soft
  vim.g.gruvbox_material_background = "soft"
  vim.g.gruvbox_material_enable_italic = 1
  vim.g.gruvbox_material_better_performance = 1

  vim.cmd([[colorscheme gruvbox-material]])
end

M.nord = function()
  vim.cmd([[colorscheme nord]])
end

M.everforest = function()
  vim.g.everforest_enable_italic = 1
  vim.g.everforest_better_performance = 1

  vim.cmd([[colorscheme everforest]])
end

M.nightfox = function()
  vim.cmd([[colorscheme nordfox]])
end

M.kanagawa = function()
  vim.cmd([[colorscheme kanagawa]])
end

M.catppuccin = function()
  require("catppuccin").setup({
    flavour = "mocha", -- Can be one of: latte, frappe, macchiato, mocha
    term_colors = true,
    transparent_background = false,
    styles = {
      comments = {},
      conditionals = {},
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
    },
    color_overrides = {
      mocha = {
        rosewater = "#F5E0DC",
        flamingo = "#F2CDCD",
        mauve = "#DDB6F2",
        pink = "#F5C2E7",
        red = "#F28FAD",
        maroon = "#E8A2AF",
        peach = "#F8BD96",
        yellow = "#FAE3B0",
        green = "#ABE9B3",
        blue = "#96CDFB",
        sky = "#89DCEB",
        teal = "#B5E8E0",
        lavender = "#C9CBFF",

        text = "#D9E0EE",
        subtext1 = "#BAC2DE",
        subtext0 = "#A6ADC8",
        overlay2 = "#C3BAC6",
        overlay1 = "#988BA2",
        overlay0 = "#6E6C7E",
        surface2 = "#6E6C7E",
        surface1 = "#575268",
        surface0 = "#302D41",

        base = "#1E1E2E",
        mantle = "#1A1826",
        crust = "#161320",
      },
    },
    highlight_overrides = {
      mocha = function(mocha)
        return {
          TabLineSel = { bg = mocha.pink },
        }
      end,
    },
  })

  vim.cmd([[colorscheme catppuccin]])
end

M.rose_pine = function()
  require('rose-pine').setup({
    --- @usage 'main' | 'moon'
    dark_variant = 'moon',
  })

  -- set colorscheme after options
  vim.cmd('colorscheme rose-pine')
end

M.onedarkpro = function()
  require("onedarkpro").setup({
    dark_theme = "onedark", -- The default dark theme
  })

  -- set colorscheme after options
  vim.cmd('colorscheme onedarkpro')
end

M.monokai = function()
  vim.cmd('colorscheme monokai_pro')
end

M.material = function ()
  vim.g.material_style = "oceanic"
  vim.cmd('colorscheme material')
end

M.set_colorscheme = function(colorscheme)
  if not vim.tbl_contains(vim.tbl_keys(M), colorscheme) then
    local msg = "Invalid colorscheme: " .. colorscheme
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })

    return
  end

  -- Load the colorscheme, because all the colorschemes are declared as opt plugins, so the colorscheme isn't loaded yet.
  local status = utils.add_pack(M.colorscheme2dir[colorscheme])

  if not status then
    local msg = string.format("Colorscheme %s is not installed. Run PackerSync to install.", colorscheme)
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })

    return
  end

  -- Load the colorscheme and its settings
  M[colorscheme]()

  M.colorscheme = colorscheme

  if vim.g.logging_level == "debug" then
    local msg = "Colorscheme: " .. colorscheme

    vim.notify(msg, vim.log.levels.DEBUG, { title = "nvim-config" })
  end
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
  M.set_colorscheme(colorscheme)
  vim.notify(string.format("Colorscheme changed to \"%s\".", colorscheme),
    vim.log.levels.NOTICE, { title = "nvim-config" })
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
  M.set_colorscheme(colorscheme)
  vim.notify(string.format("Colorscheme changed to \"%s\".", colorscheme),
    vim.log.levels.NOTICE, { title = "nvim-config" })
end

--- Use a random colorscheme from the pre-defined list of colorschemes.
M.rand_colorscheme = function()
  local colorscheme = utils.rand_element(vim.tbl_keys(M.colorscheme2dir))
  M.set_colorscheme(colorscheme)
end

return M
