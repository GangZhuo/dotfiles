" Fix key mapping issues for GUI
inoremap <silent> <S-Insert>  <C-R>+
cnoremap <S-Insert> <C-R>+
nnoremap <silent> <C-6> <C-^>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                          config for nvim-qt                          "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" To check if neovim-qt is running, use `exists('g:GuiLoaded')`,
" see https://github.com/equalsraf/neovim-qt/issues/219
if exists('g:GuiLoaded')
  " call GuiWindowMaximized(1)
  GuiTabline 0
  GuiPopupmenu 0
  GuiLinespace 2
  "GuiFont! Hack\ NF:h10:l
  GuiFont! InconsolataGo\ NFM:h14:l
endif

