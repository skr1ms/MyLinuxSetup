-- lua/plugins/dart.lua
return {
  -- LSP dartls
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dartls = {
          -- можно явно указать dart из NixOS-профиля:
          -- cmd = { "/etc/profiles/per-user/takuya/bin/dart", "language-server", "--protocol=lsp" },
        },
      },
    },
  },

  -- Treesitter для Dart
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "dart" },
    },
  },
}
