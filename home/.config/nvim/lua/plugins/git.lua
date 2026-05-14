return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next git hunk")
        map("n", "[h", gs.prev_hunk, "Previous git hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset git hunk")
        map("n", "<leader>hb", gs.blame_line, "Blame line")
      end,
    },
  },
}
