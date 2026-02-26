return {
  'stevearc/conform.nvim',

  config = function()
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        go = { 'gofmt' },
        html = { 'prettierd' },
        helm = { 'helm_ls' },
        json = { 'biome' },
        jsonc = { 'biome' },
        lua = { 'stylua' },
        markdown = { 'mdformat' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        toml = { 'taplo' },
      },
      format_on_save = { lsp_format = 'fallback' },
      formatters = {
        mdformat = {
          prepend_args = { '--wrap', '88' },
        },
      },
    })
  end,
}
