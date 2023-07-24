local proxy_url = vim.env.https_proxy or vim.env.http_proxy
if proxy_url ~= nil and proxy_url ~= "" then
  -- Remove trailing slash
  proxy_url = string.gsub(proxy_url, "(.-)/*$", "%1")
  vim.g.copilot_proxy = proxy_url
end

require("copilot").setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})

require("copilot_cmp").setup({
})

