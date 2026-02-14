return {
  'toppair/peek.nvim',
  event = { 'VeryLazy' },
  build = 'deno task --quiet build:fast',
  config = function()
    local peek = require('peek')
    peek.setup()

    local toggle_peek = function()
      if peek.is_open() then
        peek.close()
      else
        peek.open()
      end
    end

    vim.keymap.set('n', '<leader>p', toggle_peek, { desc = 'Toggle [P]eek' })
  end,
}
