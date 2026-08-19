return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            },
          },
        },
      })

      -- Keymaps to switch between open tabs
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { silent = true })
    end,
  },
}
