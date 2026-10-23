-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Switch buffers with <C-p>
vim.keymap.set("n", "<C-p>", function()
  Snacks.picker.buffers()
end, { desc = "Switch Buffer" })

-- Toggle file explorer with <C-n>
vim.keymap.set("n", "<C-n>", function()
  Snacks.explorer()
end, { desc = "Explorer Snacks (root dir)" })
