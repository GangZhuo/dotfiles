require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "auto",
    -- component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
    section_separators = "",
    component_separators = "",
    disabled_filetypes = { "vista_kind" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", },
    lualine_c = {
      "filename",
      require('myconfig.plugins.statusline.spell'),
      require('myconfig.plugins.statusline.func-name'),
    },
    lualine_x = {
      "encoding",
      {
        "fileformat",
        symbols = {
          unix = "unix",
          dos = "win",
          mac = "mac",
        },
      },
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = {
      "location",
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        color = { bg = "NONE", },
      },
      require('myconfig.plugins.statusline.trailing-whitespace'),
      require('myconfig.plugins.statusline.mixed-indent'),
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "quickfix", "fugitive", "nvim-tree" },
}
