return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      if opts and opts.move and opts.move.keys then
        if opts.move.keys.goto_next_start then
          opts.move.keys.goto_next_start["]c"] = nil
        end
        if opts.move.keys.goto_previous_start then
          opts.move.keys.goto_previous_start["[c"] = nil
        end
      end
      return opts
    end,
  },
}
