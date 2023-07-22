
vim.g.copilot_proxy = vim.env.https_proxy or vim.env.http_proxy

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("copilot_cmp").setup({
})

