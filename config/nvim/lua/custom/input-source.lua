local last_inputsource = nil
local normal_mode_inputsource = 'com.apple.keylayout.ABC'

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    local result = vim.system({ 'is' }):wait(1000)
    if result.code ~= 0 then
      vim.notify('is: failed to get input source: ' .. result.stderr, vim.log.levels.ERROR)
      return
    end
    last_inputsource = vim.trim(result.stdout)
    result = vim.system({ 'is', normal_mode_inputsource }):wait(1000)
    if result.code ~= 0 then
      vim.notify('is: failed to set input source: ' .. result.stderr, vim.log.levels.ERROR)
    end
  end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  callback = function()
    if not last_inputsource then
      return
    end
    local result = vim.system({ 'is', last_inputsource }):wait(1000)
    if result.code ~= 0 then
      vim.notify('is: failed to set input source: ' .. result.stderr, vim.log.levels.ERROR)
    end
  end,
})
