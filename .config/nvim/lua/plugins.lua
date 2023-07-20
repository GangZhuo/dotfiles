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

    -- A list of colorscheme plugin you may want to try. Find what suits you.
    use { "sainnhe/sonokai",             opt = true }
    use { "folke/tokyonight.nvim",       opt = true }

    -- LSP
    use { "neovim/nvim-lspconfig",
      config = [[ require("config.lsp") ]],
    }

    -- Standalone UI for nvim-lsp progress
    use { "j-hui/fidget.nvim", branch = "legacy",
      config = [[ require("config.fidget") ]],
    }

    -- build a concrete syntax tree, and highlight by syntax tree
    use { "nvim-treesitter/nvim-treesitter",
      run = [[ require("nvim-treesitter.install").update()() ]],
      config = [[ require("config.treesitter") ]],
    }

    -- Resume last cursor position
    use { "ethanholz/nvim-lastplace",
      config = [[ require("config.lastplace") ]],
    }

    -- Escape from insert mode by 'jk'
    use { "nvim-zh/better-escape.vim",
      config = [[ vim.g.better_escape_interval = 200 ]],
    }

    -- Colorizer
    use { "norcalli/nvim-colorizer.lua",
      config = [[ require("config.nvim-colorizer") ]],
    }

    require("trailing-whitespace").setup({
      enable = true,
      mi = {
        enable = false,
      },
    })

    -- Ultra fold in Neovim base on lsp, treesitter and indent
    use { "kevinhwang91/nvim-ufo",
      requires = "kevinhwang91/promise-async",
      config = [[ require("config.ufo") ]],
    }

    -- Modern matchit implementation base on treesitter
    use { "andymass/vim-matchup",
      config = [[ require("config.matchup") ]],
    }

    -- Show marks in signcolumn
    use { "kshenoy/vim-signature",
      config = [[ require("config.signature") ]],
    }

    -- Show match number and index for searching
    use { "kevinhwang91/nvim-hlslens",
      config = [[ require("config.hlslens") ]],
    }

    -- Best quickfix
    use { "kevinhwang91/nvim-bqf",
      config = [[ require("config.bqf") ]],
    }

    -- file explorer
    use { "kyazdani42/nvim-tree.lua",
      requires = "kyazdani42/nvim-web-devicons",
      config = [[ require("config.nvim-tree") ]],
    }

    -- fuzzy finder
    use { "nvim-telescope/telescope.nvim",
      requires = {
        { "nvim-lua/plenary.nvim" },
        { "kyazdani42/nvim-web-devicons" },
        { "nvim-telescope/telescope-fzf-native.nvim", run = 'make' },
        { "nvim-telescope/telescope-live-grep-args.nvim" },
      },
      config = [[ require("config.telescope") ]],
    }

    -- Snippet
    use { "hrsh7th/vim-vsnip",
      config = [[ require("config.vsnip") ]],
    }
    use { "hrsh7th/vim-vsnip-integ", }
    use { "rafamadriz/friendly-snippets", }

    -- auto-completion engine
    use { "hrsh7th/nvim-cmp",
      -- lsp kind icons
      requires = "onsails/lspkind-nvim",
      config = [[ require("config.nvim-cmp") ]],
    }

    -- nvim-cmp completion sources
    use { "hrsh7th/cmp-nvim-lsp", }
    use { "hrsh7th/cmp-path", }
    use { "hrsh7th/cmp-buffer", }
    use { "hrsh7th/cmp-vsnip", }
    use { "hrsh7th/cmp-cmdline", }
    use { "dmitmel/cmp-cmdline-history", }
    use { "uga-rosa/cmp-dictionary",
      config = [[ require("config.cmp-dictionary") ]],
    }

    -- status line
    use { "nvim-lualine/lualine.nvim",
      config = [[ require("config.statusline") ]],
    }

    -- buffer line
    use { "akinsho/bufferline.nvim",
      config = [[ require("config.bufferline") ]],
    }

    -- notification plugin
    use { "rcarriga/nvim-notify",
      config = function()
        vim.defer_fn(function()
          require("config.nvim-notify")
        end, 1000)
      end,
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

