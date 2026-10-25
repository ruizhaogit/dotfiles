-- Snacks picker tweaks
-- Make <C-n> close the explorer when it's focused, instead of the picker's
-- default `list_down` (which overrides the global <C-n> toggle mapping)
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true, -- search hidden files (dotfiles) in file search
        },
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
        grep = {
          hidden = true, -- search hidden files (e.g. .vimrc) in live grep
        },
        git_log = {
          actions = {
            -- diff two commits: select both with <Tab>, then press D.
            -- Opens each changed file's old/new version side-by-side (vim diff)
            diff_two = function(picker)
              local sel = picker:selected()
              if #sel < 2 then
                Snacks.notify("Select two commits with <Tab> first", { level = "WARN" })
                return
              end
              local newer, older = sel[1].commit, sel[2].commit
              local cwd = picker:cwd()
              local out = vim.fn.system({ "git", "-C", cwd, "diff", "--name-only", older, newer })
              if vim.v.shell_error ~= 0 then
                Snacks.notify("git diff failed:\n" .. out, { level = "ERROR" })
                return
              end
              local files = vim.split(out, "\n", { trimempty = true })
              if #files == 0 then
                Snacks.notify("No file changes between these commits", { level = "WARN" })
                return
              end

              --- scratch buffer holding one commit's version of `path`
              local function version_buf(commit, path)
                local content = vim.fn.system({ "git", "-C", cwd, "show", commit .. ":" .. path })
                if vim.v.shell_error ~= 0 then
                  content = "" -- file doesn't exist in this commit (added/deleted)
                end
                local buf = vim.api.nvim_create_buf(false, true)
                vim.bo[buf].buftype = "nofile"
                vim.bo[buf].bufhidden = "wipe"
                vim.bo[buf].filetype = vim.filetype.match({ filename = path }) or ""
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n", { trimempty = true }))
                vim.api.nvim_buf_set_name(buf, commit:sub(1, 7) .. ":" .. vim.fn.fnamemodify(path, ":t"))
                return buf
              end

              -- one tab per changed file: old | new with diff mode on
              for i, path in ipairs(files) do
                if i > 1 then
                  vim.cmd("tabnew")
                else
                  vim.cmd("tab split")
                end
                vim.api.nvim_win_set_buf(0, version_buf(older, path))
                vim.cmd("vsplit")
                vim.api.nvim_win_set_buf(0, version_buf(newer, path))
                vim.cmd("windo diffthis")
              end
            end,
          },
          win = {
            input = {
              keys = {
                ["D"] = { "diff_two", mode = { "n" } },
              },
            },
            list = {
              keys = {
                ["D"] = "diff_two",
              },
            },
          },
        },
      },
    },
  },
}
