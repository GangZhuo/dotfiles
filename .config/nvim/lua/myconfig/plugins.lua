
local ensure_packer = function()
  local fn = vim.fn
  local api = vim.api
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup {
  function(use)

    -- Packer can manage itself
    use { "wbthomason/packer.nvim" }

    -- A list of colorscheme plugin you may want to try. Find what suits you.
    use { "sainnhe/sonokai",             opt = true }
    use { "rebelot/kanagawa.nvim",       opt = true }

    -- LSP
    use { "neovim/nvim-lspconfig",
      config = [[ require("myconfig.plugins.lsp") ]],
    }

    -- Standalone UI for nvim-lsp progress
    use { "j-hui/fidget.nvim", branch = "legacy",
      config = [[ require("myconfig.plugins.fidget") ]],
    }

    -- build a concrete syntax tree, and highlight by syntax tree
    use { "nvim-treesitter/nvim-treesitter",
      run = [[ require("nvim-treesitter.install").update()() ]],
      config = [[ require("myconfig.plugins.treesitter") ]],
    }

    -- Resume last cursor position
    use { "ethanholz/nvim-lastplace",
      config = [[ require("myconfig.plugins.lastplace") ]],
    }

    -- Escape from insert mode by 'jk'
    use { "nvim-zh/better-escape.vim",
      config = [[ vim.g.better_escape_interval = 200 ]],
    }

    -- Colorizer
    use { "norcalli/nvim-colorizer.lua",
      config = [[ require("myconfig.plugins.colorizer") ]],
    }

    require("myconfig.trailing-whitespace").setup({
      enable = true,
      mi = {
        enable = false,
      },
    })

    -- Ultra fold in Neovim base on lsp, treesitter and indent
    use { "kevinhwang91/nvim-ufo",
      requires = "kevinhwang91/promise-async",
      config = [[ require("myconfig.plugins.ufo") ]],
    }

    -- Modern matchit implementation base on treesitter
    use { "andymass/vim-matchup",
      config = [[ require("myconfig.plugins.matchup") ]],
    }

    -- Show marks in signcolumn
    use { "kshenoy/vim-signature",
      config = [[ require("myconfig.plugins.signature") ]],
    }

    -- Show match number and index for searching
    use { "kevinhwang91/nvim-hlslens",
      config = [[ require("myconfig.plugins.hlslens") ]],
    }

    -- Best quickfix
    use { "kevinhwang91/nvim-bqf",
      config = [[ require("myconfig.plugins.bqf") ]],
    }

    -- file explorer
    use { "kyazdani42/nvim-tree.lua",
      requires = "kyazdani42/nvim-web-devicons",
      config = [[ require("myconfig.plugins.tree") ]],
    }

    -- fuzzy finder
    use { "nvim-telescope/telescope.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "kyazdani42/nvim-web-devicons" },
        { "nvim-telescope/telescope-fzf-native.nvim", run = 'make' },
        { "nvim-telescope/telescope-live-grep-args.nvim" },
      },
      config = [[ require("myconfig.plugins.telescope") ]],
    }

    -- Snippet
    use { "L3MON4D3/LuaSnip",
      run = "make install_jsregexp",
      config = [[ require("myconfig.plugins.luasnip") ]],
    }
    use { "rafamadriz/friendly-snippets", }

    -- auto-completion engine
    use { "hrsh7th/nvim-cmp",
      -- lsp kind icons
      requires = "onsails/lspkind-nvim",
      config = [[ require("myconfig.plugins.cmp") ]],
    }

    -- nvim-cmp completion sources
    use { "hrsh7th/cmp-nvim-lsp", }
    use { "hrsh7th/cmp-path", }
    use { "hrsh7th/cmp-buffer", }
    use { "hrsh7th/cmp-cmdline", }
    use { "dmitmel/cmp-cmdline-history", }
    use { "saadparwaiz1/cmp_luasnip", }
    use { "uga-rosa/cmp-dictionary",
      config = [[ require("myconfig.plugins.cmp-dictionary") ]],
    }

    -- status line
    use { "nvim-lualine/lualine.nvim",
      config = [[ require("myconfig.plugins.statusline") ]],
    }

    -- buffer line
    use { "akinsho/bufferline.nvim",
      config = [[ require("myconfig.plugins.bufferline") ]],
    }

    -- notification plugin
    use { "rcarriga/nvim-notify",
      config = function()
        vim.defer_fn(function()
          require("myconfig.plugins.notify")
        end, 1000)
      end,
    }

    if packer_bootstrap then
      require("packer").sync()
    end

  end,
  config = {
    max_jobs = 4,
  },
}

