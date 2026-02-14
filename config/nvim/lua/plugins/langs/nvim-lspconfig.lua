return {
  'neovim/nvim-lspconfig',
  dependencies = { 'RRethy/vim-illuminate' },

  config = function()
    vim.diagnostic.config({
      virtual_text = true,
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Golang

    vim.lsp.config('gopls', {
      capabilities = capabilities,

      settings = {
        gopls = {
          staticcheck = true,
          gofumpt = false,
        },
      },
    })

    -- JSON
    vim.filetype.add({
      extension = {
        ejson = 'json', -- Treats .ejson files as 'json' filetype
        hujson = 'jsonc', -- Treats .hujson files as 'jsonc' filetype
      },
    })

    vim.lsp.config('biome', {
      capabilities = capabilities,
      filetypes = { 'json', 'jsonc' },
    })

    -- Lua
    vim.lsp.config('lua_ls', {
      capabilities = capabilities,

      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    })

    -- Python

    vim.lsp.config('ty', {
      capabilities = capabilities,
      filetypes = { 'python' },
    })

    -- Ruby

    vim.lsp.config('ruby_lsp', {
      capabilities = capabilities,
      mason = false,
    })

    vim.lsp.enable('ruby_lsp')

    -- TOML
    vim.lsp.config('taplo', {})
  end,
}
