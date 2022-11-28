local telescope = require('telescope.builtin')
map {'n', '<C-F><C-F>', '<cmd>Telescope live_grep<CR>', {noremap = true}}
map {'n', '<C-F><C-G>', '<cmd>Telescope find_files<CR>', {noremap = true}}
map {'n', '<C-F><C-T>', '<cmd>TodoTelescope<CR>', {noremap = true}}
map {'n', '<C-F><C-R>', '<cmd>Telescope lsp_references<CR>', {noremap = true}}
