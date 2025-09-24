require("config.lazy")
require("config.remap")
require("config.set")
require("config.color")

local augroup = vim.api.nvim_create_augroup
local customGroup = augroup('custom', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = customGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('BufEnter', {
    group = customGroup,
    callback = function()
        if vim.bo.filetype == "zig" then
            pcall(vim.cmd.colorscheme, "tokyonight-night")
        else
            pcall(vim.cmd.colorscheme, "rose-pine-moon")
        end
    end
})

