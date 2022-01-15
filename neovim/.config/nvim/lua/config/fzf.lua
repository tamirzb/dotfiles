local fzf_lua = require('fzf-lua')
local which_key = require('which-key')

-- A bit of a hack to make all providers that deal with files never send
-- multiple selections to quickfix
local fzf_lua_config = require('fzf-lua.config')
local actions = require('fzf-lua.actions')
fzf_lua_config.globals.files.actions.default = actions.file_edit

fzf_lua.setup({
    winopts = {
        -- FZF should take the entire neovim screen
        fullscreen = true,

        -- Display the current line in the preview as if it's selected
        hl = { cursorline = "Visual" },

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

    -- Scroll the preview window with Alt+u/d, needs to be setup for both
    -- FZF and builtin previewer
    keymap = {
        fzf = {
            ["alt-d"] = "preview-page-down",
            ["alt-u"] = "preview-page-up",
        },
        builtin = {
            ["<m-d>"] = "preview-page-down",
            ["<m-u>"] = "preview-page-up",

            -- Rotate preview with Ctrl/Alt+r
            ["<c-r>"] = "toggle-preview-ccw",
            ["<m-r>"] = "toggle-preview-cw",
        }
    },

    -- Set these to FZF's default, not fzf-lua's default
    fzf_opts = {
        ["--layout"] = false,
        ["--info"] = false
    },

    -- Don't resume last search for live workspace symbols
    lsp = { continue_last_search = false }
})

-- FZF keymaps, not including LSP ones (which are registered only for LSP
-- buffers)

which_key.register({
    e = { fzf_lua.files, "Fuzzy search files" },
    b = { fzf_lua.buffers, "Fuzzy search buffers" },
    [";"] = { fzf_lua.command_history, "Fuzzy search command history" },
    ["/"] = { fzf_lua.search_history, "Fuzzy search search history" },
    a = { function()
        -- Add "-w" to the rg opts to only show matches surrounded by word
        -- boundaries
        local rg_opts = fzf_lua_config.globals.grep.rg_opts
        rg_opts = rg_opts .. " -w"
        fzf_lua.grep_cword({ rg_opts = rg_opts })
    end, "Fuzzy search current word" }
}, { prefix = "<leader>" })

which_key.register({
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
