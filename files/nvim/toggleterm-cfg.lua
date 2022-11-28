require('toggleterm').setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    open_mapping = [[<C-t>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = '1', -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    direction = 'vertical',
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    --float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        ---border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
    --    -border = 'shadow',
    --    width = vim.o.columns * 0.5,
    --    height = vim.o.rows * 0.5,
    --    winblend = 3,
    --    highlights = {
    --        border = "Normal",
    --        background = "Normal",
    --    }
    --}
})

-- local map = require('bindkey')

-- map {'t', '<esc>', [[<C-\><C-n>]], {noremap=true, buffer=true}}
-- vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)

-- map {'t', '<C-S-Right>', '<C-n><C-W>l', {noremap = true, buffer = true}}
-- map {'t', '<C-S-Left>', '<C-n><C-W>h', {noremap = true, buffer = true}}
-- map {'t', '<C-S-Up>', '<C-n><C-W>k', {noremap = true, buffer = true}}
-- map {'t', '<C-S-Down>', '<C-n><C-W>j', {noremap = true, buffer = true}}
