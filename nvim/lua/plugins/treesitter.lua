return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- Pins plugin to the stable API branch
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "yaml",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}
