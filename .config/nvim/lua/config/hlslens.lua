local api = vim.api
local keymap = vim.keymap

local hlslens = require("hlslens")

hlslens.setup {
  -- If calm_down is true, clear all lens and highlighting When the cursor is
  -- out of the position range of the matched instance or any texts are changed
  calm_down = false,
  -- Only add lens for the nearest matched instance and ignore others
  nearest_only = false,
  -- When to open the floating window for the nearest lens.
  --   'auto': floating window will be opened if room isn't enough for virtual text;
  --   'always': always use floating window instead of virtual text;
  --   'never': never use floating window for the nearest lens
  nearest_float_when = 'auto'
}

local activate_hlslens = function(direction)
  local cmd = string.format("normal! %s%s", vim.v.count1, direction)
  local status, msg = pcall(vim.cmd, cmd)

  if not status then
    -- 13 is the index where real error message starts
    msg = msg:sub(13)
    api.nvim_err_writeln(msg)
    return
  end

  hlslens.start()
end

keymap.set("n", "n", "", {
  callback = function()
    activate_hlslens("n")
  end,
})

keymap.set("n", "N", "", {
  callback = function()
    activate_hlslens("N")
  end,
})

keymap.set("n", "*", "", {
  callback = function()
    vim.fn.execute("normal! *N")
    hlslens.start()
  end,
})
keymap.set("n", "#", "", {
  callback = function()
    vim.fn.execute("normal! #N")
    hlslens.start()
  end,
})
keymap.set("n", "<BackSpace>", function ()
  require('hlslens').stop()
  vim.cmd('nohl')
end)
