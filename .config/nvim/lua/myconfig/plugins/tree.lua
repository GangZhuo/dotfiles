local keymap = vim.keymap
local nvim_tree = require("nvim-tree")
local api = require("nvim-tree.api")

local function edit(mode, node)
  local path = node.absolute_path
  if node.link_to and not node.nodes then
    path = node.link_to
  end
  require("nvim-tree.actions.node.open-file").fn(mode, path)
end

local expand = function()
  local node = api.tree.get_node_under_cursor()
  if node.nodes then
    if not node.open then
      require("nvim-tree.lib").expand_or_collapse(node)
    end
  elseif node.parent then
    edit("edit", node)
  end
end

local collapse = function()
  local node = api.tree.get_node_under_cursor()
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

local function on_attach(bufnr)
  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  api.config.mappings.default_on_attach(bufnr)

  keymap.set('n', 'l', expand,   opts('Expand folder or open a file'))
  keymap.set('n', 'h', collapse, opts('Collapse the folder'))
  keymap.set('n', '?', api.tree.toggle_help, opts('Help'))

end

nvim_tree.setup {
  sync_root_with_cwd = true,
  diagnostics = {
    enable = true,
    debounce_delay = 1000,
    show_on_dirs = true,
  },
  on_attach = on_attach,
  view = {
    adaptive_size = false,
    centralize_selection = true,
    width = 40,
    side = "left",
    number = true,
    relativenumber = true,
    signcolumn = "yes",
  },
  renderer = {
    group_empty = true,
  },
}

-- Show workspace file tree
keymap.set("n", "<leader>t", function()
  return api.tree.toggle(true, false)
end, { silent = true, desc = "toggle nvim-tree" })
