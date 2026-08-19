return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Custom action: open selection with system default viewer (xdg-open) 🚪
      local open_with_system = function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local filepath = selection.value or selection[1]
        vim.ui.open(filepath)
      end

      require("telescope").setup({
        defaults = {
          mappings = {
            i = { ["<C-o>"] = open_with_system }, -- Ctrl + o in search mode
            n = { ["<C-o>"] = open_with_system }, -- Ctrl + o in normal mode
          },
        },
      })

      -- Standard Telescope Keymaps 🗝️
      vim.keymap.set("n", "<Leader>ff", builtin.find_files, { silent = true })
      vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { silent = true })
      vim.keymap.set("n", "<Leader>fb", builtin.buffers, { silent = true })
    end,
  },
}
