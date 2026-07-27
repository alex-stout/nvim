return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            local ensure_installed = {
                "vimdoc", "javascript", "typescript", "c", "lua", "rust",
                "jsdoc", "bash", "go", "python", "markdown", "markdown_inline",
            }

            ts.install(ensure_installed)

            local max_filesize = 100 * 1024
            local uv = vim.uv or vim.loop

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    local buf = ev.buf
                    local ft = ev.match
                    
                    -- ignore for html files
                    if ft == "html" then
                        return
                    end

                    -- disable on large files for performance
                    local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        vim.notify(
                            "file larger than 100kb treesitter disabled for performance",
                            vim.log.levels.WARN,
                            { title = "treesitter" }
                        )
                        return
                    end

                    -- Map filetype to parser language
                    local lang = vim.treesitter.language.get_lang(ft)
                    if not lang then
                        return
                    end

                    local function start()
                        -- pcall: parser may still be missing/compiling.
                        if not pcall(vim.treesitter.start, buf, lang) then
                            return
                        end
                        
                        -- Experimental treesitter-based indentation.
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        -- Old config: `additional_vim_regex_highlighting = { "markdown" }`.
                        -- Keep regex syntax on for markdown, off elsewhere (treesitter replaces it).
                        vim.bo[buf].syntax = (ft == "markdown") and "on" or "off"
                    end

                    if vim.tbl_contains(ts.get_installed("parsers"), lang) then
                        start()
                    elseif vim.tbl_contains(ts.get_available(), lang) then
                        -- auto_install: fetch the parser, then enable highlighting.
                        ts.install(lang):await(function(err)
                            if not err then
                                vim.schedule(start)
                            end
                        end)
                    end
                end,
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
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
