local last_inputsource = nil
local normal_mode_inputsource = 'com.apple.keylayout.ABC'

local IS = {}

IS.verify_install = function()
  return vim.fn.executable('input-source') == 1
end

IS.get_current_input_source = function()
  local result = vim.system({ 'input-source' }):wait(1000)
  if result.code ~= 0 then
    vim.notify('input-source: failed to get input source: ' .. result.stderr, vim.log.levels.ERROR)
    return
  end
  return vim.trim(result.stdout)
end

IS.set_input_source = function(input_source)
  local result = vim.system({ 'input-source', input_source }):wait(1000)
  if result.code ~= 0 then
    vim.notify('input-source: failed to set input source: ' .. result.stderr, vim.log.levels.ERROR)
  end
end

IS.debug = function()
  if IS.verify_install() then
    vim.notify('Last Input Source: ' .. last_inputsource)
    return
  end

  vim.notify('`is` not found in PATH')
end

vim.api.nvim_create_user_command('ISDebug', IS.debug, {})

if not IS.verify_install() then
  return
end

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    last_inputsource = IS.get_current_input_source()
    IS.set_input_source(normal_mode_inputsource)
  end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
  callback = function()
    if not last_inputsource then
      return
    end
    IS.set_input_source(last_inputsource)
  end,
})
