return { 
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local config = require("nvim-treesitter")
    config.setup({
      highlight = { enable = true },
      indent = { enable = true },
      autotage = { enable = true },
      ensure_installed = { "lua", "tsx", "jsx", "javascript", "typescript", "c" },
      auto_install = true,
    })
  end
}
