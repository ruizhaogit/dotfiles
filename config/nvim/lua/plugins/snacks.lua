-- Snacks picker tweaks
-- Make <C-n> close the explorer when it's focused, instead of the picker's
-- default `list_down` (which overrides the global <C-n> toggle mapping)
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show dotfiles, so reveal works for hidden files/dirs
          win = {
            input = {
              keys = {
                ["<c-n>"] = { "close", mode = { "i", "n" } },
              },
            },
            list = {
              keys = {
                ["<c-n>"] = "close",
              },
            },
          },
        },
      },
    },
  },
}
