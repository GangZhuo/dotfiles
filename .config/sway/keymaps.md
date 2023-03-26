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
| n    | <space>e  | Put diagnostic to qf                                                                     |
| n    | <space>l  | Put diagnostic to loclist                                                                |
| n    | \x        | Close qf and location list                                                               |
| n    | [d        | Previous diagnostic                                                                      |
| n    | ]d        | Next diagnostic                                                                          |
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

