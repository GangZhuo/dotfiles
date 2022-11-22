local lspkind = require("lspkind")

local kind_labels = setmetatable({ }, {
  __index = function(_, kind)
    return lspkind.symbolic(kind, {
      mode = "symbol",
    })
  end,
})

require("lsp-status").config({
  kind_labels = kind_labels,
  current_function = true,
  show_filename = false,
  diagnostics = false,
})

-- Do not redraw
require("lsp-status.redraw").redraw = function() end
