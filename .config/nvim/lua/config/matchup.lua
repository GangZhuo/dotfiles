-- Improve performance
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_timeout = 100
vim.g.matchup_matchparen_insert_timeout = 30

vim.g.matchup_surround_enabled = 1

-- Whether to enable matching inside comment or string
vim.g.matchup_delim_noskips = 0

-- Show offscreen match pair in popup window
vim.g.matchup_matchparen_offscreen = { method = 'popup' }

vim.keymap.set("n", "<leader>k", "<cmd>MatchupWhereAmI?<cr>", { desc = "matchup: where am i" })
