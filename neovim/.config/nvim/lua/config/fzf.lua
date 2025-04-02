local fzf_lua = require('fzf-lua')
local utils = require('config.utils')

-- When fzf-lua searches for files (fzf_lua.files) it allows hidden files are
-- ok but ignores files in .git. This behavior is not replicated by default in
-- fzf_lua.grep*, so we do it ourselves.
local rg_opts = "--hidden --glob=!*.git " ..
                fzf_lua.config.globals.grep.rg_opts

-- fzf-lua adds ctrl-g as an action in some modes. We have our own use for it
-- so remove the action.
local remove_ctrl_g_action = {
    actions = {
        ["ctrl-g"] = false
    }
}

fzf_lua.setup({
    winopts = {
        -- FZF should take the entire neovim screen
        fullscreen = true,

        preview = {
            -- The preview should take half the screen
            vertical = "up:50%",
            horizontal = "right:50%",

            -- Load and display the preview immediately, without delay
            delay = 0,

            winopts = {
                -- Display the line numbers in the preview window
                number = true,
                -- Display tabs in the preview window
                list = true,
            },

            -- Since we have line numbers, there's no need for the scrollbar
            scrollbar = false
        },
    },

    -- Display the current line in the preview as if it's selected
    hls = { cursorline = "Visual" },

    keymap = {
        fzf = {
            -- Not sure why but fzf-lua ends up removing this specific keymap
            -- from FZF_DEFAULT_OPTS, so re-set it
            ["ctrl-u"] = "half-page-up",
        },
        builtin = {
            -- Scroll the preview window with Alt+u/d. Already set in FZF
            -- config but needs to also be set for fzf-lua's builtin.
            ["<m-d>"] = "preview-page-down",
            ["<m-u>"] = "preview-page-up",

            -- Rotate preview with Ctrl/Alt+r
            ["<c-r>"] = "toggle-preview-ccw",
            ["<m-r>"] = "toggle-preview-cw",
        }
    },

    -- Set these to FZF's default, not fzf-lua's default
    fzf_opts = {
        ["--layout"] = "default",
        ["--info"] = "default"
    },

    -- Don't resume last search for live workspace symbols
    lsp = { continue_last_search = false },

    grep = { rg_opts = rg_opts, actions = remove_ctrl_g_action.actions },

    -- Overwrite default actions for all providers that deal with files in
    -- order to make them not send multiple selections to quickfix by default
    actions = {
        files = {
            ["default"] = fzf_lua.actions.file_edit,
            ["ctrl-x"] = fzf_lua.actions.file_split,
            ["ctrl-v"] = fzf_lua.actions.file_vsplit,
            ["alt-q"] = fzf_lua.actions.file_sel_to_qf,
        },
    },

    -- Remove ctrl-g from some modes
    files = remove_ctrl_g_action,
    tags = remove_ctrl_g_action,
    awesome_colorschemes = remove_ctrl_g_action,
})

-- fzf-lua wants you to first call `:FzfLua grep` then write the search in
-- another prompt, I prefer everything in a single command. This also allows
-- adding flags to rg.
-- This can even support flags for rg, e.g. `:FzfLuaGrep -i case-insensitive`.
-- To use this to search for a string with spaces use
-- `:FzfLuaGrep string\ with\ spaces`.
vim.api.nvim_create_user_command("FzfLuaGrep", function(opts)
    -- The search string should be the last argument. Take it out of the array.
    local args_len = #opts.fargs
    local search = opts.fargs[args_len]
    table.remove(opts.fargs, args_len)

    -- The rest of the arguments should be flags
    local cur_rg_opts = rg_opts
    for _, arg in ipairs(opts.fargs) do
        -- All flags should start with a hyphen
        assert(arg:sub(1,1) == "-", "Received an argument that is not a flag")
        cur_rg_opts = cur_rg_opts .. " " .. arg
    end

    fzf_lua.grep({ search = search, rg_opts = cur_rg_opts })
end, { nargs = "+" })

-- FZF keymaps, not including LSP ones (which are registered only for LSP
-- buffers)

utils.which_key_register({
    e = { fzf_lua.files, "Fuzzy search files" },
    b = { fzf_lua.buffers, "Fuzzy search buffers" },
    [";"] = { fzf_lua.command_history, "Fuzzy search command history" },
    ["/"] = { fzf_lua.search_history, "Fuzzy search search history" },
    z = { fzf_lua.resume, "Resume last fuzzy search" },
    a = { fzf_lua.grep_cword, "Fuzzy search current word" },
    s = { ":FzfLuaGrep ", "Prompt to search" },

    -- The tags keybindings are basically fallback, to be overwritten if LSP is
    -- active
    t = { fzf_lua.btags, "Fuzzy search current buffer tags" },
    T = { fzf_lua.tags, "Fuzzy search ctags" }
}, { prefix = "<leader>", silent = false })

utils.which_key_register({
    a = { function()
        -- This doesn't work if we are selecting more than one line
        local _, start_row, _, _ = unpack(vim.fn.getpos("."))
        local _, end_row, _, _ = unpack(vim.fn.getpos("v"))
        if start_row == end_row then
            fzf_lua.grep_visual()
        end
    end, "Fuzzy search current selection" }
}, { mode = "x", prefix = "<leader>" })

-- TODO: Re-implement :FromIndex and :AgIndex in lua, which previously existed
-- using fzf.vim and vimscript. For reference, here is the previous vimscript
-- implementation:
--
-- " Setup :FromIndex
-- " Like :FZF, but uses an file index as list of possible files to open
-- " File index path is stored in g:index_file, which by default is 'files'
-- " The idea is kind of like tags file
-- let g:index_file = "files"
-- function! s:from_index()
--     if !filereadable(g:index_file)
--         echoerr "Couldn't find file '" . g:index_file . "'"
--         return
--     endif
--     call fzf#vim#files("", {"source": "cat " . g:index_file})
-- endfunction
-- command! FromIndex call s:from_index()
--
-- function! s:ag_index(query)
--     if !filereadable(g:index_file)
--         echoerr "Couldn't find file '" . g:index_file . "'"
--         return
--     endif
--     call fzf#vim#grep("xargs -a " . g:index_file . " -d '\\n' ag --nogroup --column --color " . a:query, 0)
-- endfunction
-- command! -nargs=+ AgIndex call s:ag_index(<q-args>)
--
-- command! -bang -complete=dir -nargs=+ Ag call fzf#vim#ag_raw(<q-args>, <bang>-1)
