local M = {}

local function toggle_line(line)
  local new_line, count = line:gsub('%- %[x%]', '- [ ]')
  if count == 0 then
    new_line = line:gsub('%- %[ %]', '- [x]')
  end
  return new_line
end

M.toggle = function()
  vim.api.nvim_set_current_line(toggle_line(vim.api.nvim_get_current_line()))
end

M.toggle_visual = function()
  local a, b = vim.fn.line('v'), vim.fn.line('.')
  local start_line = math.min(a, b) - 1
  local end_line = math.max(a, b)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  for i, line in ipairs(lines) do
    lines[i] = toggle_line(line)
  end
  vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
end

return M
