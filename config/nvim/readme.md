# Summary

*-- Stable --*

This setup mainly follows the one written by
[btkramm](https://github.com/btkramm/dotfiles/tree/main/config/nvim), just because it's
not bloated.

## LSP

All LSPs are configured with nvim-lspconfig. Most are installed with mason Some need
extra configs

### Python

`ty` is used as LPS and `ruff` is used as formatter, linter. Both are installed with
mason, but ruff must be disabled to not override `ty`

```lua
-- config/nvim/lua/plugins/langs/mason-lspconfig.lua
-- ...
  opts = {
    automatic_enable = {
      exclude = {
        "ruff"
      }
    }
  },
-- ...
```

### Ruby

Ruby versions are managed with `rbenv`, which conflitcs with Mason, so `ruby-lsp` is
installed as gem managed by `rbenv` and the explicitly enabled in nvim-lspconfig:

```lua
-- config/nvim/lua/plugins/langs/nvim-lspconfig.lua

  -- Ruby

  vim.lsp.config('ruby_lsp', {
    capabilities = capabilities,
    mason = false,
  })

  vim.lsp.enable('ruby_lsp')
-- ...
```
