return {
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,
    keys = {
      { "<leader>A", function() require("harpoon"):list():append() end, desc = "harpoon file", },
      { "<leader>a", function() local harpoon = require("harpoon") harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "harpoon quick menu", },
      { "<A-7>", function() require("harpoon"):list():select(1) end, desc = "harpoon to file 1", },
      { "<A-8>", function() require("harpoon"):list():select(2) end, desc = "harpoon to file 2", },
      { "<A-9>", function() require("harpoon"):list():select(3) end, desc = "harpoon to file 3", },
      { "<A-0>", function() require("harpoon"):list():select(4) end, desc = "harpoon to file 4", },
    },
  }
}
