local M = {}

M.check = function()
  vim.health.start('input-source')
  if vim.fn.executable('is') == 1 then
    vim.health.ok('`is` found in PATH')
  else
    vim.health.warn('`is` not found in PATH', { 'Install `is` to enable input source switching' })
  end
end

return M
