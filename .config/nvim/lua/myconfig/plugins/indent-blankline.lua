require("indent_blankline").setup({
  --char = '▏',
  char = '',
  show_end_of_line = false,
  disable_with_nolist = true,
})

local api = vim.api
local gid = api.nvim_create_augroup("indent_blankline", { clear = true })
api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  group = gid,
  command = "IndentBlanklineDisable",
})

api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  group = gid,
  command = "IndentBlanklineEnable",
})
