vim.g.mapleader = ','

local set = vim.opt

-- ignore case while searching
set.ignorecase = true

-- bottom bar height
set.cmdheight = 2

-- disable audio/visual bells
set.errorbells = false
set.visualbell = false

-- more width for fold column
set.foldcolumn = "auto"

-- line numbers
set.number = true
set.relativenumber = true

-- dark bg
set.background = "dark"
set.termguicolors = true
vim.cmd[[colorscheme evening]]

-- UTF-8
set.encoding = "UTF8"

-- file endings
set.ffs = "unix,dos"

-- remove backups (we use git anyways)
set.backup = false
set.wb = false
set.swapfile = false

-- undo
set.undodir = os.getenv("HOME") .. "/.cache/nvim/undo"
set.undofile = true

-- indent
set.smartindent = true
set.expandtab = true
set.tabstop = 4
set.shiftwidth = 4

-- auto indent
set.ai = true

-- smart indent
set.si = true

-- wrap lines
set.wrap = true

-- clipboard
set.clipboard = "unnamedplus"
