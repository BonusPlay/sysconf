-- unbind space
map {'n', '<space>', '<nop>', {noremap=true}}

-- highlight current word with #
map {'v', '#', ":<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>", {silent=true, noremap=true}}

-- move between windows
map {'', '<C-Right>', '<C-W>l'}
map {'', '<C-Left>', '<C-W>h'}
map {'', '<C-Up>', '<C-W>k'}
map {'', '<C-Down>', '<C-W>j'}

-- move between tabs
map {'', '<leader>tc', ':tabnew<cr>'}
map {'', '<leader>to', ':tabonly<cr>'}
map {'', '<leader>tx', ':tabclose<cr>'}
map {'', '<leader>tm', ':tabmove<cr>'}
map {'', '<leader>tn', ':tabnext<cr>'}

map {'', '<leader>t1', '1gt<cr>'}
map {'', '<leader>t2', '2gt<cr>'}
map {'', '<leader>t3', '3gt<cr>'}
map {'', '<leader>t4', '4gt<cr>'}
map {'', '<leader>t5', '5gt<cr>'}
map {'', '<leader>t6', '6gt<cr>'}
map {'', '<leader>t7', '7gt<cr>'}
map {'', '<leader>t8', '8gt<cr>'}
map {'', '<leader>t9', '9gt<cr>'}

-- resize splits
map {'', '<C-S-Left>', ':vertical resize +1<cr>'}
map {'', '<C-S-Right>', ':vertical resize -1<cr>'}

-- clipboard
map {'n', '<leader>y', '"+y', {noremap = true}}
map {'v', '<leader>y', '"+y', {noremap = true}}
map {'n', '<leader>p', '"+p', {noremap = true}}
map {'v', '<leader>p', '"+p', {noremap = true}}

-- helper to exit terminal
map {'t', '<esc>', '<C-\\><C-n><CR>', {noremap = true}}
