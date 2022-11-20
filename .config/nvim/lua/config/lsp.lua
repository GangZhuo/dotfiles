local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local utils = require("utils")

local map = function(mode, l, r, desc)
  local opts = {
    noremap = true,
    silent = true,
    desc = desc,
  }
  keymap.set(mode, l, r, opts)
end

map('n', '<space>e', diagnostic.open_float, "put diagnostic to qf")
map('n', '<space>l', diagnostic.setloclist, "put diagnostic to loclist")
map('n', '[d',       diagnostic.goto_prev,  "previous diagnostic")
map('n', ']d',       diagnostic.goto_next,  "next diagnostic")

local custom_attach = function(client, bufnr)

  local bufmap = function(mode, l, r, desc)
    local opts = {
      noremap = true,
      silent = true,
      buffer = bufnr,
      desc = desc,
    }
    keymap.set(mode, l, r, opts)
  end

  bufmap("n", "gD",        vim.lsp.buf.declaration,    "go to declaration")
  bufmap("n", "gd",        vim.lsp.buf.definition,     "go to definition")
  bufmap("n", "gi",        vim.lsp.buf.implementation, "go to implementation")
  bufmap("n", "gr",        vim.lsp.buf.references,     "show references")
  bufmap("n", "K",         vim.lsp.buf.hover,          "show help")
  bufmap("n", "<C-k>",     vim.lsp.buf.signature_help, "show signature help")
  bufmap("n", "<space>rn", vim.lsp.buf.rename,         "varialbe rename")
  bufmap("n", "<space>ca", vim.lsp.buf.code_action,    "LSP code action")
  bufmap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "add workspace folder")
  bufmap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "remove workspace folder")
  bufmap("n", "<space>wl",
    function()
      inspect(vim.lsp.buf.list_workspace_folders())
    end,                                               "list workspace folder")

  -- Set some key bindings conditional on server capabilities
  if client.server_capabilities.documentFormattingProvider then
    bufmap("n", "<space>fc", vim.lsp.buf.format,       "format code")
  end

  api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local float_opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always", -- show source in diagnostic popup window
        prefix = " ",
      }

      if not vim.b.diagnostics_pos then
        vim.b.diagnostics_pos = { nil, nil }
      end

      local cursor_pos = api.nvim_win_get_cursor(0)
      if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
          and #diagnostic.get() > 0
      then
        diagnostic.open_float(nil, float_opts)
      end

      vim.b.diagnostics_pos = cursor_pos
    end,
  })

  if vim.g.logging_level == "debug" then
    local msg = string.format("Language server %s started!", client.name)
    vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
  end
end

local notifies = {}
local attach = function(lang_server)
  return function(...)
    if not notifies[lang_server] then
      notifies[lang_server] = true
      vim.notify(string.format("lsp setup language server '%s'!", lang_server),
        vim.log.levels.INFO, { title = "Nvim-config" })
    end
    custom_attach(...)
  end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")

if utils.executable("pylsp") then
  lspconfig.pylsp.setup {
    on_attach = attach("pylsp"),
    settings = {
      pylsp = {
        plugins = {
          pylint = { enabled = true, executable = "pylint" },
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          jedi_completion = { fuzzy = true },
          pyls_isort = { enabled = true },
          pylsp_mypy = { enabled = true },
        },
      },
    },
    flags = {
      debounce_text_changes = 200,
    },
    capabilities = capabilities,
  }
end

if utils.executable('pyright') then
  lspconfig.pyright.setup{
    on_attach = attach("pyright"),
    capabilities = capabilities
  }
end

if utils.executable("clangd") then
  lspconfig.clangd.setup {
    on_attach = attach("clangd"),
    capabilities = capabilities,
    filetypes = { "c", "cpp", "cc" },
    flags = {
      debounce_text_changes = 500,
    },
  }
end

-- set up vim-language-server
if utils.executable("vim-language-server") then
  lspconfig.vimls.setup {
    on_attach = attach("vim-language-server"),
    flags = {
      debounce_text_changes = 500,
    },
    capabilities = capabilities,
  }
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
  lspconfig.bashls.setup {
    on_attach = attach("bash-language-server"),
    capabilities = capabilities,
  }
end

if utils.executable("lua-language-server") then
  -- settings for lua-language-server can be found on https://github.com/sumneko/lua-language-server/wiki/Settings .
  lspconfig.sumneko_lua.setup {
    on_attach = attach("lua-language-server"),
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files,
          -- see also https://github.com/sumneko/lua-language-server/wiki/Libraries#link-to-workspace .
          -- Lua-dev.nvim also has similar settings for sumneko lua, https://github.com/folke/lua-dev.nvim/blob/main/lua/lua-dev/sumneko.lua .
          library = {
            fn.stdpath("data") .. "/site/pack/packer/opt/emmylua-nvim",
            fn.stdpath("config"),
          },
          maxPreload = 2000,
          preloadFileSize = 50000,
        },
      },
    },
    capabilities = capabilities,
  }
end

-- Change diagnostic signs.
fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

-- global config for diagnostic
diagnostic.config {
  underline = false,
  virtual_text = false,
  signs = true,
  severity_sort = true,
}

-- lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
--   underline = false,
--   virtual_text = false,
--   signs = true,
--   update_in_insert = false,
-- })

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
