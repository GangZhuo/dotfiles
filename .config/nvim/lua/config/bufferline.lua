require("bufferline").setup {
  options = {
    numbers = "ordinal",
    close_command = "bdelete! %d",
    right_mouse_command = nil,
    left_mouse_command = "buffer %d",
    middle_mouse_command = nil,
    indicator = {
      icon = "▎", -- this should be omitted if indicator style is not 'icon'
      style = "icon",
    },
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 18,
    max_prefix_length = 15,
    tab_size = 10,
    diagnostics = false,
    custom_filter = function(bufnr)
      -- if the result is false, this buffer will be shown, otherwise, this
      -- buffer will be hidden.

      -- filter out filetypes you don't want to see
      local exclude_ft = { "qf", "fugitive", "git" }
      local cur_ft = vim.bo[bufnr].filetype
      local should_filter = vim.tbl_contains(exclude_ft, cur_ft)

      if should_filter then
        return false
      end

      return true
    end,
    show_buffer_icons = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    separator_style = "bar",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = "id",
  },
}

-- Go to a certain buffer
vim.keymap.set("n", "gt", function(args)
    if vim.v.count == 0 then
      vim.cmd("bnext")
    else
      require("bufferline").go_to_buffer(vim.v.count)
    end
end, {
  desc = "go to buffer by ordinal number",
})
vim.keymap.set("n", "<leader>1", "<cmd>lua require('bufferline').go_to_buffer(1)<cr>", { desc = "go to first buffer", })
vim.keymap.set("n", "<leader>2", "<cmd>lua require('bufferline').go_to_buffer(2)<cr>", { desc = "go to 2nd buffer", })
vim.keymap.set("n", "<leader>3", "<cmd>lua require('bufferline').go_to_buffer(3)<cr>", { desc = "go to 3rd buffer", })
vim.keymap.set("n", "<leader>4", "<cmd>lua require('bufferline').go_to_buffer(4)<cr>", { desc = "go to 4th buffer", })
vim.keymap.set("n", "<leader>5", "<cmd>lua require('bufferline').go_to_buffer(5)<cr>", { desc = "go to 5th buffer", })
vim.keymap.set("n", "<leader>6", "<cmd>lua require('bufferline').go_to_buffer(6)<cr>", { desc = "go to 6th buffer", })
vim.keymap.set("n", "<leader>7", "<cmd>lua require('bufferline').go_to_buffer(7)<cr>", { desc = "go to 7th buffer", })
vim.keymap.set("n", "<leader>7", "<cmd>lua require('bufferline').go_to_buffer(8)<cr>", { desc = "go to 8th buffer", })
vim.keymap.set("n", "<leader>9", "<cmd>lua require('bufferline').go_to_buffer(9)<cr>", { desc = "go to 9th buffer", })
vim.keymap.set("n", "<leader>$", "<cmd>lua require('bufferline').go_to_buffer(-1)<cr>", { desc = "go to last buffer", })
