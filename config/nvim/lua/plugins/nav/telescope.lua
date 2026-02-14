return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope-live-grep-args.nvim',
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<Tab>'] = actions.toggle_selection,
          },
          n = {
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<Tab>'] = actions.toggle_selection,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          file_ignore_patterns = { '^.git/' },
        },
      },
      extensions = {
        live_grep_args = {
          hidden = true,
          file_ignore_patterns = {
            '^.git/',
            '%.lock$',
            '*/__pycache__/',
          },
        },
      },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')

    local builtin = require('telescope.builtin')

    local opts = {
      cwd = vim.fn.stdpath('config'),
      prompt_title = vim.fn.stdpath('config'),
      file_ignore_patterns = { '^.git/' },
    }

    vim.keymap.set('n', '<leader>nc', function()
      builtin.find_files(opts)
    end, { desc = 'Search [N]eovim [C]onfig files' })
  end,
  keys = function()
    local builtin = require('telescope.builtin')
    return {
      { '<D-p>', '<cmd>Telescope find_files<cr>', desc = 'Find Files' },
      { '<D-S-f>', '<cmd>Telescope live_grep_args<cr>', desc = 'Grep Files' },
      { '<D-k>', builtin.lsp_definitions, desc = 'Jump to Definition' },
    }
  end,
}
