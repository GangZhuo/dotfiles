require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  ignore_install = {}, -- List of parsers to ignore installing
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
    disable = { 'help' }, -- list of language that will be disabled
  },
  matchup = {
    enable = true,
  },
}
