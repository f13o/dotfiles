return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,

  opts = {
    lsp_file_methods = { enabled = true, timeour_ms = 2000, autosave_changes = true },
    float = {
      preview_split = 'right',
    },

    view_options = {
      show_hidden = true,
    },

    use_default_keymaps = false,
    keymaps = {
      ['<CR>'] = 'actions.select',

      ['h'] = 'actions.parent',
      ['l'] = 'actions.select',

      ['<Esc>'] = 'actions.close',
      ['q'] = 'actions.close',

      ['<D-.>'] = 'actions.toggle_hidden',
      ['<D-/>'] = 'actions.toggle_trash',
    },
  },
  keys = {
    {
      '<D-S-e>',
      function()
        if vim.bo.filetype ~= 'oil' then
          require('oil').open_float()

          vim.defer_fn(function()
            require('oil').open_preview()
          end, 100)
        end
      end,
      desc = 'Oil - Open',
    },
  },
}
