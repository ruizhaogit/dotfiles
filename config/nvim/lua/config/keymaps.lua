-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Switch buffers with <C-p>
vim.keymap.set("n", "<C-p>", function()
  Snacks.picker.buffers()
end, { desc = "Switch Buffer" })

-- File explorer: toggle with <C-n> / <leader>e, reveal current file with \ <C-r>
local function explorer_visible()
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    if not picker.closed and picker.layout then
      for _, win in pairs(picker.layout.wins or {}) do
        if win:valid() then
          return picker
        end
      end
    end
  end
end

-- (Re)open the explorer rooted at the current file's project root and reveal it
local function explorer_open_and_reveal()
  -- kill any stale (hidden) explorer pickers so we never end up with two
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    pcall(function()
      picker:close()
    end)
  end

  local file = vim.api.nvim_buf_get_name(0)
  local root = file ~= "" and LazyVim.root({ buf = 0 }) or LazyVim.cwd()
  local Tree = require("snacks.explorer.tree")
  -- LazyVim.root() falls back to the launch cwd; if the file still isn't under
  -- it (loose file outside the project), root the explorer at its directory
  if file ~= "" and not Tree:in_cwd(root, file) then
    root = vim.fs.dirname(file)
  end
  if file == "" then
    Snacks.explorer({ cwd = root })
    return
  end

  -- Reveal via on_show: a scheduled Snacks.explorer.reveal() races with picker
  -- creation and can open a second explorer
  local Actions = require("snacks.explorer.actions")
  Snacks.explorer({
    cwd = root,
    on_show = function(picker)
      Tree:open(file)
      Actions.update(picker, { target = file, refresh = true })
    end,
  })
end

-- Reveal the current file in the explorer without closing it if it's open
local function explorer_reveal()
  local picker = explorer_visible()
  local file = vim.api.nvim_buf_get_name(0)
  if not picker or file == "" then
    explorer_open_and_reveal()
    return
  end
  local Tree = require("snacks.explorer.tree")
  if not Tree:in_cwd(picker:cwd(), file) then
    -- file lives outside the explorer's cwd: re-root and reopen
    explorer_open_and_reveal()
    return
  end
  local Actions = require("snacks.explorer.actions")
  Tree:open(file)
  Actions.update(picker, { target = file, refresh = true })
end

-- Plain toggle: open/close the explorer at the project root, no reveal
local function explorer_toggle()
  local picker = explorer_visible()
  if picker then
    picker:close()
  else
    Snacks.explorer({ cwd = LazyVim.root() })
  end
end

vim.keymap.set("n", "<C-n>", explorer_toggle, { desc = "Explorer Snacks (toggle)" })
vim.keymap.set("n", "<leader>e", explorer_toggle, { desc = "Explorer Snacks (toggle)" })
vim.keymap.set("n", "\\<C-r>", explorer_reveal, { desc = "Explorer: reveal file" })

-- Git status for the current file's repo (default mapping uses nvim's cwd,
-- which shows nothing when nvim was launched outside the repo)
vim.keymap.set("n", "<leader>gs", function()
  Snacks.picker.git_status({ cwd = LazyVim.root.git() })
end, { desc = "Git Status (Root Dir)" })
-- Disable Lazy mapping on <leader>l so it acts cleanly as a prefix
vim.keymap.del("n", "<leader>l")

vim.keymap.set("n", "<leader>lg", "<leader>gs", { remap = true, desc = "Git Status (Root Dir)" })
vim.keymap.set("n", "<leader>ls", "<leader>ss", { remap = true, desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>r", "<leader>sg", { remap = true, desc = "Grep (Root Dir)" })
vim.keymap.set({ "n", "x" }, "<leader>lr", function()
  Snacks.picker.grep({
    cwd = LazyVim.root(),
    search = function(picker)
      return picker:word()
    end,
  })
end, { desc = "Grep Current Word (Root Dir)" })
vim.keymap.set("n", "<leader>lf", "<leader>ff", { remap = true, desc = "Find Files (Root Dir)" })
vim.keymap.set("n", "<leader>lc", "<leader>ut", { remap = true, desc = "Toggle Treesitter Context" })

-- Diff mode declutter (ported from old vim config):
-- <leader>lo shows more content (wrap, hide numbers/signcolumn)
-- <leader>li restores the chrome (nowrap, numbers/signcolumn back)
vim.keymap.set({ "n", "x" }, "<leader>lo", function()
  vim.cmd.windo("set wrap foldcolumn=0 signcolumn=no nonumber norelativenumber")
end, { desc = "Diff zoom out (hide UI chrome)" })

vim.keymap.set({ "n", "x" }, "<leader>li", function()
  vim.cmd.windo("set nowrap signcolumn=yes number relativenumber")
end, { desc = "Diff zoom in (restore UI chrome)" })

-- Next / previous git hunk (or diff change in diff mode)
vim.keymap.set("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "]c", bang = true })
  else
    local gs = package.loaded.gitsigns
    if gs then
      gs.nav_hunk("next")
    else
      vim.cmd.normal({ "]c", bang = true })
    end
  end
end, { desc = "Next Hunk / Diff Change" })

vim.keymap.set("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal({ "[c", bang = true })
  else
    local gs = package.loaded.gitsigns
    if gs then
      gs.nav_hunk("prev")
    else
      vim.cmd.normal({ "[c", bang = true })
    end
  end
end, { desc = "Prev Hunk / Diff Change" })
