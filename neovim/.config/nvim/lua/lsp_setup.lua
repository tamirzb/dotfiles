local M = {}

local lsp_status = require('lsp-status')
local which_key = require('which-key')

-- Set LSP related settings only after a language server is attached
local on_attach = function(client, bufnr)
    lsp_status.on_attach(client)

    -- Options to use when navigating diagnostics
    local diag_goto_opts = { wrap = false }
    local diag_goto_error_opts = vim.tbl_extend("force", diag_goto_opts,
        { severity = vim.diagnostic.severity.ERROR })

    -- Keymaps are sort of based on the README of nvim-lspconfig

    -- Keymaps in normal mode
    which_key.register({
        -- Like ctags Ctrl+], but with <leader>
        -- TODO: Possibly change this to Ctrl+] (and maybe put Ctrl+] in
        --       another keymap) once I feel this can more or less replace
        --       ctags
        ["<leader>]"] = { vim.lsp.buf.definition, "Go to definition" },
        -- Show a floating window with information about current symbol
        ["<leader>h"] = { vim.lsp.buf.hover, "Symbol info" },

        -- Show the diagnostic message for the current line (in case it's too
        -- long to be displayed fully)
        ["<leader>d"] = { vim.diagnostic.open_float, "Diagnostics info" },
        -- Navigate between diagnostic messages
        ["[d"] = { function() vim.diagnostic.goto_prev(diag_goto_opts) end,
                   "Prev diagnostic" },
        ["]d"] = { function() vim.diagnostic.goto_next(diag_goto_opts) end,
                   "Next diagnostic" },
        -- Navigate only between error diagnostic messages
        ["[D"] = {
            function() vim.diagnostic.goto_prev(diag_goto_error_opts) end,
            "Prev error diagnostic"
        },
        ["]D"] = {
            function() vim.diagnostic.goto_next(diag_goto_error_opts) end,
            "Next error diagnostic"
        }
    }, { buffer = bufnr })

    -- Keymaps in insert mode
    which_key.register({
        -- Use the omnifunc for Ctrl+N
        ["<c-n>"] = { function ()
            -- This hack is needed so when we're in the middle of a "normal"
            -- Ctrl+N (i.e. performed via Ctrl+X,Ctrl+N) and we press Ctrl+N,
            -- it will continue with the normal one and not use the omnifunc
            if vim.fn.pumvisible() == 1 then
                vim.api.nvim_input("<c-x><c-n>")
            else
                vim.lsp.omnifunc(1)
            end
        end, "LSP omnifunc complete" },

        -- Use the "regular" Ctrl+N with Ctrl+X,Ctrl+N
        ["<c-x><c-n>"] = { "<c-n>", "Regular Ctrl+N" }
    }, {mode = "i", buffer = bufnr })
end

M.clangd = {
    on_attach = on_attach,
    handlers = lsp_status.extensions.clangd.setup(),
    capabilities = lsp_status.capabilities,
    init_options = {
        clangdFileStatus = true
    },
    cmd = {
        "clangd",
        -- These should make clangd faster
        "--background-index", "--pch-storage=memory",
        -- Don't print too much to the lsp log
        "--log=error"
    }
}

-- Setup all language servers
function M.setup()
    -- Put in the global namespace to be easily accessible from
    -- vimscript/keymaps
    _G.lsp_setup = M
    require('lspconfig').clangd.setup(M.clangd)
    lsp_status.register_progress()
end

vim.diagnostic.config({
    -- Disable diagnostics signs (which add a column at the left of a
    -- buffer)
    signs = false,
    -- Don't update diagnostics in insert mode
    update_in_insert = false,
    -- Show more severe diagnostics before less severe ones
    severity_sort = true,
    -- Show the source of each diagnostic
    virtual_text = { source = "always" },
    float = {
        source = "always",
        -- Can't move the cursor to inside the floating window
        focusable = false,
        -- Hide the floating window pretty much when anything happens
        close_events = { "BufLeave", "CursorMoved", "InsertEnter",
                         "FocusLost" }
    }
})

lsp_status.config({
    show_filename = false
})

-- Print the numbers of all diagnostic types in the current buffer
function status_diagnostics()
    local result = {}

    local function add_status(status)
        if status then
            table.insert(result, status)
        end
    end

    add_status(lsp_status.status_errors())
    add_status(lsp_status.status_warnings())
    add_status(lsp_status.status_info())
    add_status(lsp_status.status_hints())

    return table.concat(result, " ")
end

-- Don't display anything if we're in insert, insert completion or replace
-- modes
function make_status_func(func)
    local quiet_modes = { "i", "ic", "R" }

    function result()
        if (#vim.lsp.buf_get_clients() == 0 or
            vim.tbl_contains(quiet_modes, vim.api.nvim_get_mode().mode)) then
            return ""
        end

        return func()
    end

    return result
end

M.status_diagnostics = make_status_func(status_diagnostics)
M.status_progress = make_status_func(lsp_status.status_progress)

return M
