local api = vim.api
local fn = vim.fn

--- Install packer if it has not been installed.
--- Return:
--- true: if this is a fresh install of packer
--- false: if packer has been installed
local function packer_ensure_install()
  -- Where to install packer.nvim -- the package manager (we make it opt)
  local packer_dir = vim.fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

  if fn.glob(packer_dir) ~= "" then
    return false
  end

  -- Auto-install packer in case it hasn't been installed.
  vim.api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})

  local packer_repo = "https://github.com/wbthomason/packer.nvim"
  local install_cmd = string.format("!git clone --depth=1 %s %s", packer_repo, packer_dir)
  vim.cmd(install_cmd)

  return true
end


local fresh_install = packer_ensure_install()

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

local packer = require("packer")
local packer_util = require("packer.util")

packer.startup {
  function(use)

    -- Packer can manage itself
    use { "wbthomason/packer.nvim", opt = true }

    -- Resume last cursor position
    use { "ethanholz/nvim-lastplace", config = [[require('config.lastplace')]] }

    ------------------------------------------------------------------------
    --                          Colorscheme                               --
    ------------------------------------------------------------------------
    -- A list of colorscheme plugin you may want to try. Find what suits you.
    use { "navarasu/onedark.nvim",       opt = true }
    use { "sainnhe/edge",                opt = true }
    use { "sainnhe/sonokai",             opt = true }
    use { "sainnhe/gruvbox-material",    opt = true }
    use { "shaunsingh/nord.nvim",        opt = true }
    use { "sainnhe/everforest",          opt = true }
    use { "EdenEast/nightfox.nvim",      opt = true }
    use { "rebelot/kanagawa.nvim",       opt = true }
    use { "catppuccin/nvim",             opt = true, as = "catppuccin" }
    use { "rose-pine/neovim",            opt = true, as = 'rose-pine' }
    use { "olimorris/onedarkpro.nvim",   opt = true }
    use { "tanvirtin/monokai.nvim",      opt = true }
    use { "marko-cerovac/material.nvim", opt = true }

    -- Escape from insert mode by 'jk'
    use { "nvim-zh/better-escape.vim",
      config = function()
        --vim.cmd([[let g:better_escape_interval = 200]])
      end,
    }

    -- Repeat vim motions
    use { "tpope/vim-repeat" }

    -- Colorizer
    use "norcalli/nvim-colorizer.lua"

    -- build a concrete syntax tree, and highlight by syntax tree
    use { "nvim-treesitter/nvim-treesitter",
      run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
      end,
      config = function()
        require('config.treesitter')
        require('trailing-whitespace').setup({
          enable = true,
          mi = {
            enable = false,
          },
        })
      end,
    }

    -- Ultra fold in Neovim base on lsp, treesitter and indent
    use { "kevinhwang91/nvim-ufo",
      after = {
        "cmp-nvim-lsp",
        "nvim-treesitter",
      },
      requires = {
        "kevinhwang91/promise-async",
      },
      config = [[require('config.ufo')]],
    }

    -- Modern matchit implementation base on treesitter
    use { "andymass/vim-matchup",
      after = {
        "nvim-treesitter",
      },
      config = [[require('utils').load_config('matchup')]],
    }

    -- Show marks in signcolumn
    use { "kshenoy/vim-signature",
      branch = "master",
      config = [[require('utils').load_config('signature')]],
    }

    -- Show match number and index for searching
    use { "kevinhwang91/nvim-hlslens",
      branch = "main",
      keys = { { "n", "*" }, { "n", "#" }, { "n", "n" }, { "n", "N" } },
      config = [[require('config.hlslens')]],
    }

    -- status line
    use { "nvim-lualine/lualine.nvim",
      config = [[require('config.statusline')]],
    }

    -- buffer line
    use { "akinsho/bufferline.nvim",
      config = [[require('config.bufferline')]],
    }

    -- Best quickfix
    use { "kevinhwang91/nvim-bqf",
      ft = "qf",
      config = [[require('config.bqf')]],
    }

    -- file explorer
    use { "kyazdani42/nvim-tree.lua",
      requires = {
        "kyazdani42/nvim-web-devicons",
      },
      config = [[require('config.nvim-tree')]],
    }

    -- show file tags in vim window
    use { "liuchengxu/vista.vim",
      config = [[require('config.vista')]],
    }

    -- fuzzy finder
    use { "nvim-telescope/telescope.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "kyazdani42/nvim-web-devicons" },
        { "nvim-telescope/telescope-fzf-native.nvim", run = 'make' },
        { "nvim-telescope/telescope-live-grep-args.nvim" },
      },
      config = [[require('config.telescope')]],
    }

    -- notification plugin
    use { "rcarriga/nvim-notify",
      config = function()
        vim.defer_fn(function()
          require("config.nvim-notify")
        end, 1000)
      end,
    }

    ------------------------------------------------------------------------
    --                          Auto-Completion                           --
    ------------------------------------------------------------------------

    -- auto-completion engine
    use { "hrsh7th/nvim-cmp",
      requires = {
        -- lsp kind icons
        "onsails/lspkind-nvim",
      },
      config = [[require('config.nvim-cmp')]],
    }

    -- Snippet
    use { "hrsh7th/vim-vsnip",
      config = [[require('config.vsnip')]],
    }
    use { "hrsh7th/vim-vsnip-integ",
      after = "vim-vsnip",
    }
    use { "rafamadriz/friendly-snippets",
      after = "vim-vsnip",
    }

    -- nvim-cmp completion sources
    use { "hrsh7th/cmp-nvim-lsp",        after = "nvim-cmp", }
    use { "hrsh7th/cmp-path",            after = "nvim-cmp", }
    use { "hrsh7th/cmp-buffer",          after = "nvim-cmp", }
    use { "hrsh7th/cmp-vsnip",           after = "nvim-cmp", }
    use { "hrsh7th/cmp-cmdline",         after = "nvim-cmp", }
    use { "dmitmel/cmp-cmdline-history", after = "nvim-cmp", }
    use { "uga-rosa/cmp-dictionary",     after = "nvim-cmp",
      config = [[require('config.cmp-dictionary')]],
    }

    -- LSP
    use { "neovim/nvim-lspconfig",
      -- nvim-lsp do not require cmp-nvim-lsp,
      -- but it's configuration relies on cmp-nvim-lsp
      after = "cmp-nvim-lsp",
      config = [[require('config.lsp')]],
    }
    -- Standalone UI for nvim-lsp progress
    use { "j-hui/fidget.nvim",
      branch = "legacy",
      after = "nvim-lspconfig",
      config = [[require("config.fidget")]],
    }

  end,
  config = {
    max_jobs = 4,
    package_root = packer_util.join_paths(vim.fn.stdpath("data"), "site", "pack"),
    compile_path = packer_util.join_paths(vim.fn.stdpath("data"), "site", "lua", "packer_compiled.lua"),
  },
}

-- For fresh install, we need to install plugins. Otherwise, we just need to require `packer_compiled.lua`.
if fresh_install then
  -- We run packer.sync() here, because only after packer.startup, can we know which plugins to install.
  -- So plugin installation should be done after the startup process.
  packer.sync()
else
  local status, _ = pcall(require, "packer_compiled")
  if not status then
    local msg = "File packer_compiled.lua not found: run PackerSync to fix!"
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
  end
end

-- Auto-generate packer_compiled.lua file
api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "*/nvim/lua/plugins.lua",
  group = api.nvim_create_augroup("packer_auto_compile", { clear = true }),
  callback = function(ctx)
    local cmd = "source " .. ctx.file
    vim.cmd(cmd)
    vim.cmd("PackerCompile")
    vim.notify("PackerCompile done!", vim.log.levels.INFO, { title = "Nvim-config" })
  end,
})

