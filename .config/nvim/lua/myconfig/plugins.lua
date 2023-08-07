
local ensure_packer = function()
  local fn = vim.fn
  local api = vim.api
  local install_path = fn.stdpath('data')
      ..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})
    fn.system({'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim', install_path})
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
    -- lsp kind icons
    use { "onsails/lspkind-nvim",
      config = [[ require("myconfig.plugins.lspkind") ]],
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

    -- automatically update your ctags file
    use { "ludovicchabant/vim-gutentags",
      config = [[ require("myconfig.plugins.gutentags") ]],
    }
    -- show file tags in vim window
    use { "liuchengxu/vista.vim",
      config = [[ require("myconfig.plugins.vista") ]],
    }

    -- Snippet
    use { "L3MON4D3/LuaSnip",
      run = "make install_jsregexp",
      config = [[ require("myconfig.plugins.luasnip") ]],
    }
    use { "rafamadriz/friendly-snippets", }

    -- auto-completion engine
    use { "hrsh7th/nvim-cmp",
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
    use { "delphinus/cmp-ctags", }
    use { "hrsh7th/cmp-nvim-lua", }

    -- Github Copilot Completion
    use { "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = "InsertEnter",
      -- will config in copilot-cmp
      -- config = [[ require("myconfig.plugins.copilot") ]],
    }
    use { "zbirenbaum/copilot-cmp",
      after = { "copilot.lua" },
      config = [[ require("myconfig.plugins.copilot") ]],
    }

    use { "lukas-reineke/indent-blankline.nvim",
      config = [[ require("myconfig.plugins.indent-blankline") ]],
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

  end,
  config = {
    max_jobs = 4,
  },
}

-- For fresh install, we need to install plugins. Otherwise,
-- we just need to require `packer_compiled.lua`.
if packer_bootstrap then
  -- We run packer.sync() here, because only after packer.startup,
  -- can we know which plugins to install.
  -- So plugin installation should be done after the startup process.
  require("packer").sync()
else
  local fn = vim.fn
  local compiled_path = fn.stdpath("config").."/plugin/packer_compiled.lua"
  if fn.empty(fn.glob(compiled_path)) > 0 then
    local msg = "File packer_compiled.lua not found: run PackerSync to fix!"
    vim.notify(msg, vim.log.levels.ERROR, { title = "nvim-config" })
  end
end

-- Auto-generate packer_compiled.lua file
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "*/nvim/lua/myconfig/plugins.lua",
  group = vim.api.nvim_create_augroup("packer_auto_compile",
      { clear = true }),
  callback = function(ctx)
    local cmd = "source " .. ctx.file
    vim.cmd(cmd)
    vim.cmd("PackerCompile")
    vim.notify("PackerCompile done!",
        vim.log.levels.INFO, { title = "Nvim-config" })
  end,
})

