-- Telescope configuration
local map = vim.keymap.set
local telescope = require('telescope')
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
local actions = require('telescope.actions')

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        ["<C-f>"] = actions.preview_scrolling_left,
        ["<C-b>"] = actions.preview_scrolling_right,
      },
      n = {
        ["l"] = actions.select_default,
        ["o"] = actions.select_default, -- Open the file

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        ["<C-f>"] = actions.preview_scrolling_left,
        ["<C-b>"] = actions.preview_scrolling_right,
      },
    }
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = 'smart_case',        -- options: 'ignore_case', 'respect_case'
    }
  }
})

--[[
-- previewer options
vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(args)
    if args.data.filetype ~= "help" then
      vim.wo.number = true
    end
    if args.data.bufname:match("*.csv") then
      vim.wo.wrap = false
    else
      vim.wo.wrap = true
    end
  end,
})
--]]

telescope.load_extension('fzf')
telescope.load_extension("live_grep_args")

local set_keymap = function (key, picker, theme, desc, opts)
  local map_opts = { noremap = true, silent = true, desc = desc }

  opts = opts or {}

  if theme ~= nil and theme ~= "" then
    opts = themes["get_"..theme](opts)
  end

  opts.prompt_title = desc

  local get_visual_selection = function ()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if #text > 0 then
      return text
    else
      return ''
    end
  end

  local reset_opts = function()
      opts.default_text = nil
      if opts and opts.grep_current_buffer then
        opts.search_dirs = { vim.api.nvim_buf_get_name(0) }
      else
        opts.search_dirs = nil
      end
  end

  local n_rhs = function()
      reset_opts()
      picker(opts)
  end
  map('n', key, n_rhs, map_opts)

  local x_rhs = function()
      reset_opts()
      opts.default_text = get_visual_selection()
      picker(opts)
  end
  map('x', key, x_rhs, map_opts)
end

local live_grep = telescope.extensions.live_grep_args.live_grep_args
local notify = telescope.extensions.notify.notify

local symbol_picker = function(opts)
  local lsp = vim.lsp
  local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
  local buf_client_num = #vim.tbl_keys(buf_clients)
  if buf_client_num > 0 then
    opts.prompt_title = "Search LSP Symbols in Workspace"
    builtin.lsp_workspace_symbols(opts)
  else
    opts.prompt_title = "Search Ctags Symbols in Workspace"
    builtin.tags(opts)
  end
end

local doc_symbol_picker = function(opts)
  local lsp = vim.lsp
  local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
  local buf_client_num = #vim.tbl_keys(buf_clients)
  if buf_client_num > 0 then
    opts.prompt_title = "Search LSP Symbols in Current Buffer"
    builtin.lsp_document_symbols(opts)
  else
    opts.prompt_title = "Search Ctags Symbols in Current Buffer"
    builtin.current_buffer_tags(opts)
  end
end

set_keymap('<leader>h', builtin.builtin,     nil, "Search Builtin Pickers")
set_keymap('<leader>f', builtin.find_files,  nil, "Search Files")
set_keymap('<leader>b', builtin.buffers,     nil, "Search Buffers", { sort_mru = true, })
set_keymap('<leader>s', live_grep,           nil, "Search in Workspace")
set_keymap('<leader>c', live_grep,           nil, "Search in Current Buffer", { grep_current_buffer = true })
set_keymap('<leader>w', symbol_picker,       nil, "Search LSP/Ctags Symbols in Workspace")
set_keymap('<leader>d', doc_symbol_picker,   nil, "Search LSP/Ctags Symbols in Current Buffer")
set_keymap('<leader>m', builtin.marks,       nil, "Search Marks")
set_keymap('<leader>M', builtin.keymaps,     nil, "Search Keymaps")
set_keymap('<leader>r', builtin.registers,   nil, "Search Registers")
set_keymap('<leader>q', builtin.quickfix,    nil, "Search Quick Fix")
set_keymap('<leader>l', builtin.loclist,     nil, "Search Location List")
set_keymap('<leader>n', notify,              nil, "Search Notify History")
