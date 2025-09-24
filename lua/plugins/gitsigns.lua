return {
    "lewis6991/gitsigns.nvim",
    config = function()
        local gitsigns = require("gitsigns")

        gitsigns.setup({
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text_pos = "right_align"
            }
        })
    end
}
