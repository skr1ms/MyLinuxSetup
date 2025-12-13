return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          cmd = { "lua-language-server" },
        },
      },
    },
  },
}
