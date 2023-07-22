local ctags_last_modified = function ()
  local path = string.format("%s/tags", vim.loop.cwd())
  local f = io.popen(string.format("stat -c %%Y \"%s\"", path))
  if f ~= nil then
    local last_modified = f:read()
    local today = os.date("%Y-%m-%d")
    local last_modified_date = os.date("%Y-%m-%d", last_modified)
    local last_modified_time = os.date("%H:%M:%S", last_modified)
    if today == last_modified_date then
      last_modified = last_modified_time
    else
      last_modified = string.format("%s %s",
          last_modified_date, last_modified_time)
    end
    f:close()
    local action = vim.fn["gutentags#statusline"]("", "", "...")
    return string.format("ctags%s:[%s]", action, last_modified)
  else
    return vim.fn["gutentags#statusline"]("", "", "ctags...")
  end
end

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
      ctags_last_modified,
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
