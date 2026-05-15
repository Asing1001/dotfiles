return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    cmd = "Telescope",
    keys = function()
      local builtin = require("telescope.builtin")

      local function project_files()
        if vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true") then
          builtin.git_files({ show_untracked = true })
        else
          builtin.find_files({ hidden = true })
        end
      end

      return {
        { "<leader>p", project_files,    desc = "Find files" },
        { "<leader>f", builtin.live_grep, desc = "Search in project" },
        { "<leader>e", "<cmd>Explore<CR>", desc = "File explorer" },
        { "<leader>b", builtin.buffers,   desc = "Switch buffers" },
      }
    end,
    opts = {
      extensions = {
        ["ui-select"] = {},
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      pcall(require("telescope").load_extension, "ui-select")
    end,
  },
}
