local parser_install_dir
local ensure_installed

if vim.fn.glob(vim.g.my_data_dir .. "/parsers") ~= "" then
  parser_install_dir = vim.g.my_data_dir .. "/parsers"
else
  parser_install_dir = vim.fn.stdpath("data") .. "/parsers"
end

vim.opt.runtimepath:append(parser_install_dir)

-- If no write access, it means that root will ensured
-- that all parsers are installed.
if vim.loop.fs_stat(parser_install_dir)
    and not vim.loop.fs_access(parser_install_dir, "RW")
    and vim.loop.fs_access(parser_install_dir .. "/parser/c.so", "R") then
  ensure_installed = {}
else
  ensure_installed = "all"
end

require("nvim-treesitter.configs").setup {
  ensure_installed = ensure_installed,
  ignore_install = {}, -- List of parsers to ignore installing
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  parser_install_dir = parser_install_dir,
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
    disable = { 'help' }, -- list of language that will be disabled
  },
  matchup = {
    enable = true,
  },
}
