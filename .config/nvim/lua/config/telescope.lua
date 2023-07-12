-- Telescope configuration
local map = vim.keymap.set
local telescope = require('telescope')
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

local _themes = {
  popup_list = {
    theme = 'popup_list',
    previewer = false,
    prompt_title = false,
    results_title = false,
    sorting_strategy = 'ascending',
    layout_strategy = 'center',
    layout_config = {
      width = 0.5,
      height = 0.3,
      mirror = true,
      preview_cutoff = 1,
    },
    borderchars = {
      prompt  = { '─', '│', '─', '│', '┌', '┐', '┤', '└' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
  },
  popup_extended = {
    theme = 'popup_extended',
    prompt_title = false,
    results_title = false,
    layout_strategy = 'center',
    layout_config = {
      width = 0.5,
      height = 0.3,
      mirror = true,
      preview_cutoff = 1,
    },
    borderchars = {
      prompt  = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
  },
  command_pane = {
    theme = 'command_pane',
    previewer = false,
    prompt_title = false,
    results_title = false,
    sorting_strategy = 'descending',
    layout_strategy = 'bottom_pane',
    layout_config = {
      height = 13,
      preview_cutoff = 1,
      prompt_position = 'bottom'
    },
  },
  ivy_plus = {
    theme = 'ivy_plus',
    prompt_title = false,
    results_title = false,
    layout_strategy = 'bottom_pane',
    layout_config = {
      height = 13,
      preview_cutoff = 120,
      prompt_position = 'bottom'
    },
    borderchars = {
      prompt  = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      results = { '─', '│', '─', '│', '┌', '┬', '┴', '└' },
      preview = { '─', '│', ' ', ' ', '─', '┐', '│', ' ' },
    },
  },
}

for k,v in pairs(_themes) do
  themes['get_'..k] = function(opts)
    opts = opts or {}
    local theme_opts = v
    if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
      theme_opts.borderchars = {
        prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
        preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      }
    end
    return vim.tbl_deep_extend("force", theme_opts, opts)
  end
end

telescope.setup({
  defaults = {
    border = true,
    prompt_title = false,
    results_title = false,
    color_devicons = false,
    layout_strategy = 'horizontal',
    borderchars = {
      prompt  = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
    layout_config = {
      bottom_pane = {
        height = 20,
        preview_cutoff = 120,
        prompt_position = 'top'
      },
      center = {
        height = 0.4,
        preview_cutoff = 40,
        prompt_position = 'top',
        width = 0.7
      },
      horizontal = {
        prompt_position = 'top',
        preview_cutoff = 40,
        height = 0.9,
        width = 0.8
      }
    },
    sorting_strategy = 'ascending',
    prompt_prefix = ' ',
    selection_caret = ' → ',
    entry_prefix = '   ',
    file_ignore_patterns = {'node_modules'},
    path_display = { 'truncate' },
    preview = {
      treesitter = {
        enable = {
          'css', 'dockerfile', 'elixir', 'erlang', 'fish',
          'html', 'http', 'javascript', 'json', 'lua', 'php',
          'python', 'regex', 'ruby', 'rust', 'scss', 'svelte',
          'typescript', 'vue', 'yaml', 'markdown', 'bash', 'c',
          'cmake', 'comment', 'cpp', 'dart', 'go', 'jsdoc',
          'json5', 'jsonc', 'llvm', 'make', 'ninja', 'prisma',
          'proto', 'pug', 'swift', 'todotxt', 'toml', 'tsx',
        }
      }
    },
    mappings = {
      n = {
        ["l"] = require("telescope.actions").select_default,
        ["o"] = require("telescope.actions").select_default, -- Open the file
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

telescope.load_extension('fzf')
telescope.load_extension("live_grep_args")

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

local set_keymap = function (key, picker, layout, desc, opts)
  local map_opts = { noremap = true, silent = true, desc = desc }

  local n_opts = {}
  if layout then
    n_opts = vim.deepcopy(_themes[layout])
  end
  n_opts.prompt_title = desc
  if type(opts) == "table" then
    for k,v in pairs(opts) do
        n_opts[k] = v
    end
  end

  local n_rhs = function()
      if vim.g.telescope_search_hidden then
        n_opts.additional_args = { '--hidden' }
      end
      if opts and opts.grep_current_buffer then
        n_opts.search_dirs = { vim.api.nvim_buf_get_name(0) }
      end
      picker(n_opts)
  end
  map('n', key, n_rhs, map_opts)

  local x_opts = vim.deepcopy(n_opts)
  local x_rhs = function()
      x_opts.default_text = get_visual_selection()
      if vim.g.telescope_search_hidden then
        x_opts.additional_args = { '--hidden' }
      end
      if opts and opts.grep_current_buffer then
        x_opts.search_dirs = { vim.api.nvim_buf_get_name(0) }
      end
      picker(x_opts)
  end
  map('x', key, x_rhs, map_opts)
end

vim.api.nvim_create_user_command(
    'TelescopeToggleHidden',
    function()
      vim.g.telescope_search_hidden = (not vim.g.telescope_search_hidden)
      local msg
      if vim.g.telescope_search_hidden then
        msg = "Telescope search hidden files 'on'!"
      else
        msg = "Telescope search hidden files 'off'!"
      end
      vim.notify(msg, vim.log.levels.INFO, { title = "Nvim-config" })
    end,
    { nargs = 0 }
)

local live_grep_args = telescope.extensions.live_grep_args.live_grep_args
local notify = telescope.extensions.notify.notify

set_keymap('<leader>h', builtin.builtin,     'popup_list',     "Search Builtin Pickers")
set_keymap('<leader>f', builtin.find_files,  'popup_extended', "Search Files")
set_keymap('<leader>b', builtin.buffers,     'popup_list',     "Search Buffers", { sort_mru = true, })
set_keymap('<leader>s', builtin.live_grep,   'popup_extended', "Search in Workspace")
set_keymap('<leader>c', builtin.live_grep,   'popup_extended', "Search in Curent Buffer", { grep_current_buffer = true })
set_keymap('<leader>g', live_grep_args,      'popup_extended', "Search by Ripgrep")
set_keymap('<leader>k', builtin.tags,        'popup_extended', "Search Tags")
set_keymap('<leader>d', builtin.lsp_document_symbols, 'popup_extended', "Search LSP Symbols in Current Buffer")
set_keymap('<leader>m', builtin.marks,       'popup_extended', "Search Marks")
set_keymap('<leader>M', builtin.keymaps,     nil,              "Search Keymaps")
set_keymap('<leader>r', builtin.registers,   'popup_list',     "Search Registers")
set_keymap('<leader>q', builtin.quickfix,    'ivy_plus',       "Search Quickfix")
set_keymap('<leader>l', builtin.loclist,     'ivy_plus',       "Search Location List")
set_keymap('<leader>n', notify,              nil,              "Search Notify History")
