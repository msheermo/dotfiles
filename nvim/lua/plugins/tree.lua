return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Visual icons for file types
    config = function()
      -- Initialize nvim-tree
      require("nvim-tree").setup({
        view = {
          width = 32,
          side = "left",
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              git = true,
            },
          },
        },
      })

      -- Shortcut: Space + e to open/close the file tree
      vim.keymap.set("n", "<Leader>e", "<cmd>NvimTreeToggle<CR>", { silent = true })
    end,
  },
}
