let $FZF_DEFAULT_COMMAND = 'rg --files'

set background=dark

let mapleader = ","
au BufRead,BufNewFile *.nix setf nix

set nocompatible
set noswapfile
set nobackup
set ignorecase

set number relativenumber

set expandtab
set shiftwidth=4
set tabstop=4

let g:coq_settings = { 'auto_start': 'shut-up' }

lua require("plugins")
lua require("bindkey")
lua require("keybinds")
lua require("user-cfg")

lua require("treesitter-cfg")
lua require("telescope-cfg")
lua require("lsp-cfg")
