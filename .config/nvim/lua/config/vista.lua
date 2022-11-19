vim.keymap.set("n", "<leader>t", "<cmd>Vista!!<cr>", {
  noremap = true,
  silent = true,
  desc = "Toggle vista view window",
})

-- Show the nearest method/function in the statusline
vim.cmd([[call vista#RunForNearestMethodOrFunction()]])
