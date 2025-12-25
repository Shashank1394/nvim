-- OPTIONS
local set = vim.opt

-- Line Numbers
set.number = true
set.relativenumber = true

-- Indentation and Tabs
set.tabstop = 2
set.shiftwidth = 2
set.autoindent = true
set.expandtab = true
set.smartindent = true

-- Search Settings
set.ignorecase = true
set.smartcase = true

-- Appearance
set.termguicolors = true
set.background = "dark"
set.signcolumn = "auto"

-- Keep cursor at least 8 rows from top/bot
set.scrolloff = 8

-- Undo dir settings
set.swapfile = false
set.backup = false
set.undodir = os.getenv("HOME") .. "/.vim/undodir"
set.undofile = true

-- Incremental Search
set.hlsearch = false
set.incsearch = true

-- Faster cursor hold
set.updatetime = 50

-- Others
set.wrap = true
