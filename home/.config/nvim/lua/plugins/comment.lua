return {
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>/", "gcc", remap = true, desc = "Toggle comment" },
      { "<leader>/", "gc", mode = "v", remap = true, desc = "Toggle comment" },
    },
  },
}
