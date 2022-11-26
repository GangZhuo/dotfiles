require("nvim-treesitter.configs").setup {
  ensure_installed = "all",
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
    disable = { 'help' }, -- list of language that will be disabled
  },
  matchup = {
    enable = true,
  },
}
