local ufo = require("ufo")

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local ftMap = {
  vim    = "indent",
  python = { "indent" },
  git = ""
}

local chainSelector = function(bufnr)
  local handleFallbackException = function(err, providerName)
    if type(err) == 'string' and err:match('UfoFallbackException') then
      return require('ufo').getFolds(bufnr, providerName)
    else
      return require('promise').reject(err)
    end
  end

  return require('ufo').getFolds(bufnr, 'lsp'):catch(function(err)
      return handleFallbackException(err, 'treesitter')
    end):catch(function(err)
      return handleFallbackException(err, 'indent')
    end)
end

ufo.setup({
  provider_selector = function(bufnr, filetype, buftype)
    return ftMap[filetype] or chainSelector
  end
})

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith)
