local keymap = vim.keymap
local nvim_tree = require("nvim-tree")

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
  elseif node.parent then
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

local set_keymap = function(key, fun, desc)
  vim.keymap.set("n", key, inject_node(fun), {
    silent = true,
    buffer = bufnr,
    desc = desc
  })
end

local attach = function(bufnr)
    set_keymap("l", expand, "expand folder/edit file")
    set_keymap("h", collapse, "collapse folder")
end

nvim_tree.setup {
  sync_root_with_cwd = true,
  diagnostics = {
    enable = true,
    debounce_delay = 1000,
    show_on_dirs = true,
  },
  on_attach = attach,
  view = {
    adaptive_size = false,
    centralize_selection = true,
    side = "left",
    number = true,
    relativenumber = true,
    signcolumn = "yes",
  },
  renderer = {
    group_empty = true,
  },
}

keymap.set("n", "<leader>f", function()
  local api = require("nvim-tree.api")
  return api.tree.toggle(true, false)
end, { silent = true, desc = "toggle nvim-tree" })
