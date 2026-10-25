-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-change to the project root on opening a file (like airblade/vim-rooter)
-- Uses window-local `lcd`; falls back to the file's directory outside any project
local rooter = vim.api.nvim_create_augroup("lazyvim_user_rooter", { clear = true })
local rooter_patterns = { ".git", ".hg", ".svn", "Makefile", "package.json", "pyproject.toml", "setup.py" }

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufFilePost" }, {
  group = rooter,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" or not vim.bo[buf].buflisted then
      return
    end
    local path = vim.api.nvim_buf_get_name(buf)
    if path == "" then
      return
    end
    local root = vim.fs.root(path, rooter_patterns) or vim.fs.dirname(path)
    if vim.fn.getcwd(0) ~= root then
      vim.cmd("silent! lcd " .. vim.fn.fnameescape(root))
    end
  end,
})

-- Disable LazyVim auto-enabling of spell checking in text/markdown files
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("lazyvim_wrap", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})
