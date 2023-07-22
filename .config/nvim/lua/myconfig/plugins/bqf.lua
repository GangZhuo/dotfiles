--[[
-- * Press <Tab> or <S-Tab> to toggle the sign of item
-- * Press zn or zN will create new quickfix list
-- * Press zf in quickfix window will enter fzf mode.
-- * Press p to toggle auto preview when cursor moved
-- * Press P to toggle preview for an item of quickfix list
-- * Press ctrl-t/ctrl-x/ctrl-v to open up an item in a new tab,
--   a new horizontal split, or in a new vertical split.
-- * Press ctrl-q to toggle sign for the selected items
-- * Press ctrl-c to close quickfix window and abort fzf

--]]
require("bqf").setup {
  auto_resize_height = true,
}
