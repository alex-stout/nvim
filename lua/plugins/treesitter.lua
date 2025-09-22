return {
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- a list of parser names, or "all"
                ensure_installed = {
                    "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                    "jsdoc", "bash", "go", "python"
                },

                -- install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- automatically install missing parsers when entering buffer
                -- recommendation: set to false if you don"t have `tree-sitter` cli installed locally
                auto_install = true,

                indent = {
                    enable = true
                },
                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "html" then
                            print("highlighting disabled for this file type")
                            return true
                        end

                        local max_filesize = 100 * 1024 -- 100 kb
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "file larger than 100kb treesitter disabled for performance",
                                vim.log.levels.warn,
                                {title = "treesitter"}
                            )
                            return true
                        end
                    end,

                    -- setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- set this to `true` if you depend on "syntax" being enabled (like for indentation).
                    -- using this option may slow down your editor, and you may see some duplicate highlights.
                    -- instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { "markdown" },
                },
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        after = "nvim-treesitter",
        config = function()
            require'treesitter-context'.setup{
                enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false, -- Enable multiwindow support.
                max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20, -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end
    }
}
