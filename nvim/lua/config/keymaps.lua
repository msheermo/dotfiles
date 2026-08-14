-- Set Space as master leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear search highlights when pressing Space + h
vim.keymap.set("n", "<Leader>h", "<cmd>nohlsearch<CR>", { silent = true })
