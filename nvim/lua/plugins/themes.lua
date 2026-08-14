return {
  -- Nord (Default dark arctic theme)
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("nord")
    end,
  },

  -- Catppuccin (Includes latte, frappe, macchiato, mocha)
  { "catppuccin/nvim", name = "catppuccin" },

  -- Gruvbox (Light/Dark support + contrast settings)
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        contrast = "hard", -- Options: "hard", "soft", or "" (medium)
      })
    end,
  },

  -- Nightfox collection (Adds 'dawnfox' as a cool light alternative)
  { "edenEast/nightfox.nvim" },

  -- Everforest
  { "sainnhe/everforest" },
}
