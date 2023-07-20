local fn = vim.fn
local api = vim.api
local diagnostic = vim.diagnostic

-- Do not use smart case in command line mode,
-- extracted from https://vi.stackexchange.com/a/16511/15292.
local augrp = api.nvim_create_augroup("dynamic_smartcase", { clear = true })
api.nvim_create_autocmd({ "CmdLineEnter" }, {
  group = augrp,
  callback = function()
    vim.o.smartcase = false
  end,
})
api.nvim_create_autocmd({ "CmdLineLeave" }, {
  group = augrp,
  callback = function()
    vim.o.smartcase = true
  end,
})

api.nvim_create_autocmd({ "TermOpen" }, {
  pattern = "*",
  group = api.nvim_create_augroup("term_settings", { clear = true }),
  callback = function()
    -- Do not use number and relative number for terminal inside nvim
    vim.bo.relativenumber = false
    vim.bo.number = false
    -- Go to insert mode by default to start typing command
    vim.cmd([[startinsert]])
  end,
})

-- More accurate syntax highlighting? (see `:h syn-sync`)
api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  group = api.nvim_create_augroup("accurate_syn_highlight", { clear = true }),
  callback = function()
    vim.cmd([[syntax sync fromstart]])
  end,
})

-- Quit Nvim if we have only one window, and its filetype match our pattern.
api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  group = api.nvim_create_augroup("auto_close_win", { clear = true }),
  callback = function()
    local quit_filetypes = {
      "qf",
      "vista",
      "NvimTree",
    }

    local should_quit = true

    local tabwins = api.nvim_tabpage_list_wins(0)
    for _,w in ipairs(tabwins) do
      local bufnr = api.nvim_win_get_buf(w)
      local bf = fn.getbufvar(bufnr, '&filetype')

      if not vim.tbl_contains(quit_filetypes, bf) then
        should_quit = false
      end
    end

    if should_quit then
      vim.cmd([[qall]])
    end
  end,
})

-- Handle large file
-- ref: https://vi.stackexchange.com/a/169/15292
api.nvim_create_autocmd({ "BufReadPre" }, {
  pattern = "*",
  group = api.nvim_create_augroup("large_file", { clear = true }),
  callback = function(args)
    local large_file = 10485760 -- 10MB
    local f = fn.expand(args.file)
    local sz = fn.getfsize(f)

    if sz > large_file or sz == -2 then
      vim.o.eventignore = vim.o.eventignore .. ",all"
      -- turning off relative number helps a lot
      vim.wo.relativenumber = false
      vim.bo.bufhidden = "unload"
      vim.bo.buftype = "nowrite"
      vim.bo.undolevels = -1
    else
      local utils = require("myconfig.utils")
      vim.o.eventignore = utils.join_arr(
        utils.remove(
          utils.split(vim.o.eventignore, ","),
          "all"))
    end
  end,
})

-- Display a message when the current file is not in utf-8 format.
-- Note that we need to use `unsilent` command here because of this issue:
-- https://github.com/vim/vim/issues/4379
api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*",
  group = api.nvim_create_augroup("non_utf8_file", { clear = true }),
  callback = function()
    if vim.bo.fileencoding ~= "utf-8" then
      vim.notify("File not in UTF-8 format!", vim.log.levels.WARN,
          { title = "nvim-config" })
    end
  end,
})

-- highlight yanked region, see `:h lua-highlight`
api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = "*",
  group = api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 300 }
  end,
})

-- Resize all windows when we resize the terminal
api.nvim_create_autocmd("VimResized", {
  group = api.nvim_create_augroup("win_autoresize", { clear = true }),
  desc = "autoresize windows on resizing operation",
  command = "wincmd =",
})

api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local float_opts = {
      focusable = false,
      close_events = {
        "BufLeave",
        "CursorMoved",
        "InsertEnter",
        "FocusLost",
      },
      border = "rounded",
      source = "always", -- show source in diagnostic popup window
      prefix = " ",
    }

    if not vim.b.diagnostics_pos then
      vim.b.diagnostics_pos = { nil, nil }
    end

    local cursor_pos = api.nvim_win_get_cursor(0)
    if (cursor_pos[1] ~= vim.b.diagnostics_pos[1]
            or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
        and #diagnostic.get() > 0
    then
      diagnostic.open_float(nil, float_opts)
    end

    vim.b.diagnostics_pos = cursor_pos
  end,
})
