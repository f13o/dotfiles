local keymap = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend('force', { noremap = true, nowait = true, silent = true }, opts or {})

  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Windows

keymap('n', '<C-[>', '<C-w>w', { desc = 'Move cursor to the previous window' })
keymap('n', '<C-]>', '<C-w>W', { desc = 'Move cursor to the next window' })

keymap('n', '<C-h>', '<C-w>h', { desc = 'Move cursor to the left window' })
keymap('n', '<C-j>', '<C-w>j', { desc = 'Move cursor to the window below' })
keymap('n', '<C-k>', '<C-w>k', { desc = 'Move cursor to the window above' })
keymap('n', '<C-l>', '<C-w>l', { desc = 'Move cursor to the right window' })

keymap('n', ',v', ':vsplit<CR>', { desc = 'Split window vertically' })
keymap('n', ',x', ':split<CR>', { desc = 'Split window horizontally' })

-- Display

keymap('n', '<C-z>', ':set wrap!<CR>', { desc = 'Toggle word wrap' })

-- Jumping

keymap('n', '<C-o>', '<C-o>zz', { desc = 'Jump backwards and center' })
keymap('n', '<C-i>', '<C-i>zz', { desc = 'Jump forward and center' })

-- Searching

keymap('n', '#', '#zz', { desc = 'Search - Word under cursor backward' })
keymap('n', '*', '*zz', { desc = 'Search - Word under cursor forward' })

keymap('n', 'N', 'Nzz', { desc = 'Search - Previous result' })
keymap('n', 'n', 'nzz', { desc = 'Search - Next result' })

keymap('n', '<ESC>', ':noh<CR>', { desc = 'Search - Clear' })

-- Selection

keymap('n', '<D-a>', 'ggVG', { desc = 'Select All' })

-- Files
keymap('n', 'yfp', ':let @+ = expand(\'%\')<CR>', { desc = '[Y]ank relative [F]ile [P]ath' })

-- Indentation

keymap('v', '<', '<gv', { desc = 'Decrease indent' })
keymap('v', '>', '>gv', { desc = 'Increase indent' })

-- LSP

keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP - [R]e[N]ame' })
keymap('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP - [G]o to [D]efinition' })

-- Lazy

keymap('n', '<leader>lu', ':Lazy update<CR>', { desc = 'Lazy Update' })

-- Write, quit, reload
keymap('n', '<D-s>', ':w<CR>', { desc = 'Write' })
keymap('i', '<D-s>', '<Esc>:w<CR>', { desc = 'Write' })

-- Lua Fun Stuff
keymap('n', '<leader>x', '<cmd>.lua<CR>', { desc = 'Execute the current line' })
keymap('n', '<leader><leader>x', '<cmd>source %<CR>', { desc = 'Execute the current file' })
