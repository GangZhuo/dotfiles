-- See :help vista-options for more information.

-- Key Mappings                                                  *vista-key-mappings*
--
-- The following mappings are defined by default in the vista window.
--
-- <CR>          - jump to the tag under the cursor.
-- <2-LeftMouse> - Same as <CR>.
-- p             - preview the tag under the context via the floating window if
--                 it's avaliable.
-- s             - sort the symbol alphabetically or the location they are
--                 declared.
-- q             - close the vista window.
--
-- You can add a mapping to `/` in order to open the vista finder for
-- searching by adding the following autocommand in your vimrc:
--  >
--  autocmd FileType vista,vista_kind nnoremap <buffer> <silent> \
--              / :<c-u>call vista#finder#fzf#Run()<CR>
--

-- How each level is indented and what to prepend.
-- This could make the display more compact or more spacious.
-- e.g., more compact: ["▸ ", ""]
-- Note: this option only works for the kind renderer, not the tree renderer.
vim.g.vista_icon_indent = { "╰─▸ ", "├─▸ " }

-- Executive used when opening vista sidebar without specifying it.
-- See all the avaliable executives via `:echo g:vista#executives`.
-- e.g. 'ale', 'coc', 'ctags', 'lcn', 'nvim_lsp', 'vim_lsc', 'vim_lsp'
vim.g.vista_default_executive = "ctags"
vim.g.vista_finder_alternative_executives = "nvim_lsp"

-- Set this option to `0` to disable echoing when the cursor moves.
vim.g.vista_echo_cursor = 1
vim.g.vista_cursor_delay = 150

-- How to show the detailed formation of current cursor symbol. Avaliable
-- options:
--
-- `echo`         - echo in the cmdline.
-- `scroll`       - make the source line of current tag at the center of the
--                window.
-- `floating_win` - display in neovim's floating window or vim's popup window.
--                See if you have neovim's floating window support via
--                `:echo exists('*nvim_open_win')` or vim's popup feature
--                via `:echo exists('*popup_create')`
-- `both`         - both `echo` and `floating_win` if it's avaliable otherwise
--                `scroll` will be used.
vim.g.vista_echo_cursor_strategy = "floating_win"
vim.g.vista_floating_border= "rounded"

-- Set the executive for some filetypes explicitly. Use the explicit executive
-- instead of the default one for these filetypes when using `:Vista` without
-- specifying the executive.
--vim.g.vista_executive_for = {
--  ["c"]   = "nvim_lsp",
--  ["cpp"] = "nvim_lsp",
--  ["lua"] = "nvim_lsp",
--  ["php"] = "nvim_lsp",
--}

-- Show symbol list
--vim.keymap.set("n", "<leader>t", "<cmd>Vista!!<cr>", {
--  noremap = true,
--  silent = true,
--  desc = "Toggle vista view window",
--})

-- Show the nearest method/function in the statusline
--vim.cmd([[call vista#RunForNearestMethodOrFunction()]])

