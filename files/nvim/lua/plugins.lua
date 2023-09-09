return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- treesitter
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use { "nvim-treesitter/nvim-treesitter-textobjects", after = "nvim-treesitter" }

  -- surround
  use { "kylechui/nvim-surround", tag = "*", config = function()
      require("nvim-surround").setup({})
  end}

  -- coq
  use { "ms-jpq/coq_nvim", branch = "coq" }

  -- lsp
  use { "neovim/nvim-lspconfig" }

  -- telescope
  use { "nvim-telescope/telescope.nvim", tag = "0.1.2", requires = {
      { "nvim-lua/plenary.nvim" }
  }}
  
  -- bottom bar
  use { "nvim-lualine/lualine.nvim", requires = {
      { "nvim-tree/nvim-web-devicons", opt = true }
  }, config = function()
      require("lualine").setup({})
  end}
end)
