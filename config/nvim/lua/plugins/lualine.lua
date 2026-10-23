-- Show cwd (and root dir) in the statusline
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- insert a cwd component before LazyVim's root_dir component;
    -- home prefix is shortened to ~
    table.insert(opts.sections.lualine_c, 1, {
      function()
        -- window-local cwd (rooter autocmds may lcd per window)
        local cwd = LazyVim.norm(vim.fn.getcwd(0))
        local home = vim.env.HOME
        if home and cwd:find(home, 1, true) == 1 then
          cwd = "~" .. cwd:sub(#home + 1)
        end
        return "󰉋 " .. cwd
      end,
      color = function()
        return { fg = Snacks.util.color("Directory") }
      end,
    })
  end,
}
