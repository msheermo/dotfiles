-- Line numbers
vim.opt.number = true          -- Show absolute line number on current line
vim.opt.relativenumber = true  -- Show relative numbers on other lines
vim.opt.cursorline = true      -- Highlight the current line for visual tracking

-- Indentation (Crucial for YAML and Ansible)
vim.opt.tabstop = 2            -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 2         -- Number of spaces for auto-indentation
vim.opt.expandtab = true       -- Convert tabs to spaces

-- Search behavior
vim.opt.ignorecase = true      -- Ignore case when searching
vim.opt.smartcase = true       -- Override ignorecase if search contains uppercase

-- UI and Performance
vim.opt.termguicolors = true   -- Enable 24-bit RGB colors
vim.opt.signcolumn = "yes"     -- Keep sign column open to avoid layout shifts
vim.opt.updatetime = 250       -- Faster completion and error popups (ms)

