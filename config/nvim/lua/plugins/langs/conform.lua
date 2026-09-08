return {
  'stevearc/conform.nvim',

  config = function()
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        go = { 'gofmt' },
        html = { 'prettierd' },
        json = { 'biome' },
        jsonc = { 'biome' },
        lua = { 'stylua' },
        markdown = { 'rumdl' },
        python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
        toml = { 'taplo' },
        yaml = { 'prettierd' },
      },
      format_on_save = { lsp_format = 'fallback' },
    })
  end,
}
