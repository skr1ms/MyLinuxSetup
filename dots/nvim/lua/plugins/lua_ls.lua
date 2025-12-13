-- lua/plugins/lua_ls.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          enabled = false,
        },
      },
    },
  },
}
