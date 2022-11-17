local keymap = vim.keymap
local nvim_tree = require("nvim-tree")

nvim_tree.setup {
  auto_reload_on_write = true,
  disable_netrw = false,
  hijack_cursor = false,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  ignore_buffer_on_setup = false,
  open_on_setup = false,
  open_on_setup_file = false,
  open_on_tab = false,
  sort_by = "name",
  update_cwd = false,
  remove_keymaps = false,
  on_attach = function(bufnr)
    local inject_node = require("nvim-tree.utils").inject_node
    local function edit(mode, node)
      local path = node.absolute_path
      if node.link_to and not node.nodes then
        path = node.link_to
      end
      require("nvim-tree.actions.node.open-file").fn(mode, path)
    end
    local expand = function(node)
      if node.nodes then
        if not node.open then
          require("nvim-tree.lib").expand_or_collapse(node)
        end
      else
        edit("edit", node)
      end
    end
    local collapse = function(node)
      if node.nodes and node.open then
        require("nvim-tree.lib").expand_or_collapse(node)
        return
      end

      -- find parent node which is opened
      local p = node
      while p.parent do
          p = p.parent
          if p.open then
              break
          end
      end

      -- if found and not a root node, collapse the node
      if p and p ~= node and p.parent and p.open then
        require("nvim-tree.lib").expand_or_collapse(p)
        require("nvim-tree.utils").focus_file(p.absolute_path)
      end
    end
    local set_keymap = function(key, fun)
      vim.keymap.set("n", key, inject_node(fun), { buffer = bufnr, noremap = true })
    end
    set_keymap("l", expand)
    set_keymap("h", collapse)
  end,
  view = {
    width = 30,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {
        -- user mappings go here
      },
    },
  },
  renderer = {
    group_empty = true,
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = true,
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  ignore_ft_on_setup = {},
  system_open = {
    cmd = "",
    args = {},
  },
  diagnostics = {
    enable = false,
    show_on_dirs = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = false,
      resize_window = false,
      window_picker = {
        enable = true,
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
}

keymap.set("n", "<leader>f", function()
  local api = require("nvim-tree.api")
  return api.tree.toggle(true, false)
end, { silent = true, desc = "toggle nvim-tree" })
