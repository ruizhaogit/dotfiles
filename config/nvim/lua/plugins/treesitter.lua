return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      if opts and opts.move and opts.move.keys and opts.move.keys.goto_next_start then
        opts.move.keys.goto_next_start["]c"] = nil
      end
      return opts
    end,
  },
}
