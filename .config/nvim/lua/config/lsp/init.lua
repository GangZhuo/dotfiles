local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local utils = require("utils")

local _notifies = {}

-- Change diagnostic signs.
fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

-- global config for diagnostic
diagnostic.config {
  virtual_text = false,
  underline = false,
  signs = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
}

-- Change border of documentation hover window,
-- See https://github.com/neovim/neovim/pull/13998.
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

require("config.lsp.fname").setup()

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

  -- Set some key bindings conditional on server capabilities
  if client.server_capabilities.documentFormattingProvider then
    bufmap("n", "<space>fc", vim.lsp.buf.format,         "format code")
  end

  require("config.lsp.fname").attach(client, bufnr)

  if not _notifies[client.name] then
    _notifies[client.name] = true
    local msg = string.format("Language server %s started!", client.name)
    vim.notify(msg, vim.log.levels.INFO, { title = "Nvim-config" })
  end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- for vsnip,
-- comment below line if you have no nvim-vsnip plugin.
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- nvim-ufo using 'foldingRange' capability,
-- comment below 4 lines if you have no nvim-ufo plugin.
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- 'j-hui/fidget.nvim' need workDoneProgress capability
capabilities.window = capabilities.window or {}
capabilities.window.workDoneProgress = true

local lspconfig = require("lspconfig")

if utils.executable("pylsp") then
  lspconfig.pylsp.setup {
    on_attach = custom_attach,
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
    on_attach = custom_attach,
    capabilities = capabilities
  }
end

if utils.executable("clangd") then
  lspconfig.clangd.setup {
    on_attach = custom_attach,
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
    on_attach = custom_attach,
    flags = {
      debounce_text_changes = 500,
    },
    capabilities = capabilities,
  }
end

-- set up bash-language-server
if utils.executable("bash-language-server") then
  lspconfig.bashls.setup {
    on_attach = custom_attach,
    capabilities = capabilities,
  }
end

if utils.executable("lua-language-server") then
  -- settings for lua-language-server can be found on https://github.com/sumneko/lua-language-server/wiki/Settings .
  lspconfig.sumneko_lua.setup {
    on_attach = custom_attach,
    capabilities = capabilities,
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
          library = {
            -- Make the server aware of Neovim runtime files
            api.nvim_get_runtime_file("", true),
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
end
