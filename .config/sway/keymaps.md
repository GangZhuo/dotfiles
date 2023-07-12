# keymaps.md

## Sway

$mod is `Mod4`

### Basics:

* $mod+Return        Start a terminal
* $mod+Shift+q       Kill focused window
* $mod+d             Start your launcher
* $mod+q             Start your web browser
* XF86HomePage       Start your web browser
* $mod+e             Start your editor
* $mod+s             Show help window
* $mod+w             Show my wiki
* $mod+Shift+c       Reload the configuration file
* $mod+Control+l     Lock your screens
* $mod+Shift+e       Exit sway
* $mod+u             Set focused window non-border
* $mod+t             Toggle border for focused window

### Moving around:

* $mod+$left         Focus left
* $mod+$down         Focus down
* $mod+$up           Focus up
* $mod+$right        Focus right
* $mod+Shift+$left   Move left
* $mod+Shift+$down   Move down
* $mod+Shift+$up     Move up
* $mod+Shift+$right  Move right
* $mod+Shift+Left    Move left
* $mod+Shift+Down    Move down
* $mod+Shift+Up      Move up
* $mod+Shift+Right   Move right

### Workspaces:

* $mod+1             Switch to workspace 1
* $mod+2             Switch to workspace 2
* $mod+3             Switch to workspace 3
* $mod+4             Switch to workspace 4
* $mod+5             Switch to workspace 5
* $mod+6             Switch to workspace 6
* $mod+7             Switch to workspace 7
* $mod+8             Switch to workspace 8
* $mod+9             Switch to workspace 9
* $mod+0             Switch to workspace 10
* $mod+Shift+1       Move container to workspace 1
* $mod+Shift+2       Move container to workspace 2
* $mod+Shift+3       Move container to workspace 3
* $mod+Shift+4       Move container to workspace 4
* $mod+Shift+5       Move container to workspace 5
* $mod+Shift+6       Move container to workspace 6
* $mod+Shift+7       Move container to workspace 7
* $mod+Shift+8       Move container to workspace 8
* $mod+Shift+9       Move container to workspace 9
* $mod+Shift+0       Move container to workspace 10

### Layout stuff:

* $mod+b             Splith horizontal
* $mod+v             Splitv vertical
* $mod+f             Toggle focused window fullscreen
* $mod+Shift+space   Toggle focused window between tiling and floating mode
* $mod+space         Swap focused window between the tiling area and the floating area
* $mod+a             Move focus to the parent container

### Scratchpad:

* $mod+Shift+minus   Move focused window to the scratchpad
* $mod+minus         Show/Hide scratchpad

### Resizing containers:

* $mod+r             Goto resize mode

  - h                Resize shrink width 40px
  - j                Resize grow height 40px
  - k                Resize shrink height 40px
  - l                Resize grow width 40px
  - Left             Resize shrink width  40px
  - Down             Resize grow height   40px
  - Up               Resize shrink height 40px
  - Right            Resize grow width    40px

  - Return           Submit resize
  - Escape           Cancel resize

### System Menu

* $mod+x             Show system menu

### Volume control

* $mod+Up            Volume +5%
* $mod+Down          Volume -5%
* $mod+m             Mute
* $mod+p             Play/Pause
* $mod+Right         Play next
* $mod+Left          Play previous
* $mod+F8            Open Pulse Audio GUI Control

### Screenshots / Screensharing

* Print              Entire screen + menu

### Output

* $mod+o             Toggle Display Output
* $mod+slash Resolution Change

## Tmux

Prefix is `C-a`

* h        Switch to left pane
* l        Switch to right pane
* j        Switch to down pane
* k        Switch to up pane
* S-Left   Switch to previous window
* S-Right  Switch to next window
* v        Split window horizontal
* H        Split window vertical

## Neovim

| Mode | Keys                   | Description                                                                 |
|:-----|:-----------------------|:----------------------------------------------------------------------------|
| i    | <c-u>                  | Turn the word under cursor to upper case                                    |
| i    | <c-t>                  | Turn the current word into title case                                       |
| i    | <A-;>                  | Insert semicolon in the end                                                 |
| i    | <C-A>                  | Go to the beginning of current line in insert mode quickly                  |
| i    | <C-E>                  | Go to the end of current line in insert mode quickly                        |
| i    | <C-D>                  | Delete the character to the right of the cursor                             |
| c    | <C-A>                  | Go to beginning of command in command-line mode                             |
| n, x | ;                      | Save key strokes (now we do not need to press shift to enter command mode)  |
| n    | <leader>y              | Copy entire buffer to system clipboard                                      |
| x    | <leader>y              | Copy selection text to system clipboard                                     |
| n, x | <leader>p              | Paste system clipboard after current cursor                                 |
| n, x | <leader>P              | Paste system clipboard before current cursor                                |
| n    | <leader>w              | Save current buffer                                                         |
| n    | \d                     | Delete a buffer, without closing the window                                 |
| n    | <space>o               | Insert a blank line below current line (do not move the cursor)             |
| n    | <space>O               | Insert a blank line above current line (do not move the cursor)             |
| n, x | H                      | Go to start of line easier                                                  |
| n, x | L                      | Go to end of line easier                                                    |
| n, x | zh                     | Go to top of the screen                                                     |
| n, x | zm                     | Go to middle of the screen                                                  |
| n, x | zl                     | Go to bottom of the screen                                                  |
| x    | <                      | Continuous visual shifting (does not exit Visual mode)                      |
| x    | >                      | Continuous visual shifting (does not exit Visual mode)                      |
| n    | <leader>ev             | Edit nvim config file quickly                                               |
| n    | <leader>sv             | Reload nvim config file quickly                                             |
| n    | <leader>v              | Reselect the text that has just been pasted                                 |
| n    | <leader>cd             | Change current working directory locally and print cwd after that           |
| t    | <Esc>                  | Use Esc to quit builtin terminal                                            |
| n, i | <F11>                  | Toggle spell checking                                                       |
| n    | <leader><space><space> | Checking Trailing-Whitespace and Mixed-Indent                               |
| n, x | <leader><space>        | Remove trailing whitespace characters                                       |
| n    | <leader>cl             | Toggle cursor column                                                        |
| n    | <C-H>                  | Switch windows                                                              |
| n    | <C-L>                  | Switch windows                                                              |
| n    | <C-K>                  | Switch windows                                                              |
| n    | <C-J>                  | Switch windows                                                              |
| n    | <A-->                  | Increase vertical size for window                                           |
| n    | <A-_>                  | Decrease vertical size for window                                           |
| n    | <A-(>                  | Increase horizontal size for window                                         |
| n    | <A-)>                  | Decrease horizontal size for window                                         |
| n    | <leader>cb             | Blink current row and column                                                |
| n    | <leader>st             | Print treesitter captures                                                   |
| n    | <BackSpace>            | Hidden highlight                                                            |
| n    | <leader>cn             | Switch to next colorscheme                                                  |
| n    | <leader>cp             | Switch to previous colorscheme                                              |

#### Navigation in the location and quickfix list

| Mode | Keys      | Description                                                                              |
|:-----|:----------|:-----------------------------------------------------------------------------------------|
| n    | <space>e  | Show diagnostics in a floating window.                                                   |
| n    | <space>l  | Add buffer diagnostics to the location list.                                             |
| n    | \x        | Close qf and location list                                                               |
| n    | [d        | Move to the previous diagnostic in the current buffer.                                   |
| n    | ]d        | Move to the next diagnostic.                                                             |
| n    | gk        | Move to the previous diagnostic in the current buffer.                                   |
| n    | gj        | Move to the next diagnostic.                                                             |
| n    | [l        | Previous location item                                                                   |
| n    | ]l        | Next location item                                                                       |
| n    | [L        | First location item                                                                      |
| n    | ]L        | Last location item                                                                       |
| n    | [q        | Previous qf item                                                                         |
| n    | ]q        | Next qf item                                                                             |
| n    | [Q        | First qf item                                                                            |
| n    | ]Q        | Last qf item                                                                             |

#### LSP

| Mode | Keys      | Description                                                                              |
|:-----|:----------|:-----------------------------------------------------------------------------------------|
| n    | gD        | Go to declaration                                                                        |
| n    | gd        | Go to definition                                                                         |
| n    | gi        | Go to implementation                                                                     |
| n    | gr        | Show references                                                                          |
| n    | K         | Show help                                                                                |
| n    | <C-k>     | Show signature help                                                                      |
| n    | <space>rn | Varialbe rename                                                                          |
| n    | <space>ca | LSP code action                                                                          |
| n    | <space>wa | Add workspace folder                                                                     |
| n    | <space>wr | Remove workspace folder                                                                  |
| n    | <space>fc | Format code                                                                              |

#### Buffer Line

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|
| n    | gb          | Go to buffer (forward) and by ordinal number                                             |
| n    | gB          | Go to buffer (backward) and by ordinal number                                            |
| n    | <leader>1~9 | Go to n buffer                                                                           |
| n    | <leader>$   | Go to last buffer                                                                        |

#### nvim-cmp

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|
| -    | <Tab>       | Select next item                                                                         |
| -    | <S-Tab>     | Select previous item                                                                     |
| -    | <CR>        | Confirm selected item                                                                    |
| -    | <C-e>       | Abort                                                                                    |
| -    | <C-b>       | Scroll down                                                                              |
| -    | <C-f>       | Scroll up                                                                                |

#### nvim-tree

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|
| n    | <leader>t   | Show/hide workspace file tree                                                            |
| n    | l           | Open a file or folder                                                                    |
| n    | h           | Collapse the folder                                                                      |
| n    | ?           | Toggle help                                                                              |

#### telescope

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|
| n, x | <leader>h   | Find Builtin Pickers                                                                     |
| n, x | <leader>f   | Find Files                                                                               |
| n, x | <leader>b   | Find Buffers                                                                             |
| n, x | <leader>s   | Search in Workspace                                                                      |
| n, x | <leader>c   | Search in Curent Buffer                                                                  |
| n, x | <leader>g   | Search by Ripgrep                                                                        |
| n, x | <leader>k   | Find Tags                                                                                |
| n, x | <leader>d   | Find LSP Symbols in Current Buffer                                                       |
| n, x | <leader>m   | Find Marks                                                                               |
| n, x | <leader>M   | Keymaps                                                                                  |
| n, x | <leader>r   | Find Registers                                                                           |
| n, x | <leader>q   | Find Quickfix                                                                            |
| n, x | <leader>l   | Find Location List                                                                       |
| n, x | <leader>n   | Find Notify History                                                                      |
| -    | l           | Open selected file                                                                       |
| -    | o           | Open selected file                                                                       |

#### Telescope Default Mappings

| Mappings       | Action                                               |
|----------------|------------------------------------------------------|
| `<C-n>/<Down>` | Next item                                            |
| `<C-p>/<Up>`   | Previous item                                        |
| `j/k`          | Next/previous (in normal mode)                       |
| `H/M/L`        | Select High/Middle/Low (in normal mode)              |
| `gg/G`         | Select the first/last item (in normal mode)          |
| `<CR>`         | Confirm selection                                    |
| `<C-x>`        | Go to file selection as a split                      |
| `<C-v>`        | Go to file selection as a vsplit                     |
| `<C-t>`        | Go to a file in a new tab                            |
| `<C-u>`        | Scroll up in preview window                          |
| `<C-d>`        | Scroll down in preview window                        |
| `<C-f>`        | Scroll left in preview window                        |
| `<C-k>`        | Scroll right in preview window                       |
| `<M-f>`        | Scroll left in results window                        |
| `<M-k>`        | Scroll right in results window                       |
| `<C-/>`        | Show mappings for picker actions (insert mode)       |
| `?`            | Show mappings for picker actions (normal mode)       |
| `<C-c>`        | Close telescope                                      |
| `<Esc>`        | Close telescope (in normal mode)                     |
| `<Tab>`        | Toggle selection and move to next selection          |
| `<S-Tab>`      | Toggle selection and move to prev selection          |
| `<C-q>`        | Send all items not filtered to quickfixlist (qflist) |
| `<M-q>`        | Send all selected items to qflist                    |


#### ufo

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|
| n    | zR          | Open all folds                                                                           |
| n    | zM          | Close all folds                                                                          |

#### vsnip

| Mode | Keys        | Description                                                                              |
|:-----|:------------|:-----------------------------------------------------------------------------------------|

