require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  ignore_install = {}, -- List of parsers to ignore installing
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  parser_install_dir = nil,
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
    disable = { 'help' }, -- list of language that will be disabled
  },
  matchup = {
    enable = true,
  },
}
