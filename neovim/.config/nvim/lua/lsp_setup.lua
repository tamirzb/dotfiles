local M = {}

local lsp_status = require('lsp-status')

-- Set LSP related settings only after a language server is attached
local on_attach = function(client, bufnr)
    lsp_status.on_attach(client)

    local function buf_set_keymap(mode, key, action, opts)
        opts = vim.tbl_extend("force", { noremap = true }, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, key, action, opts)
    end

    -- Create a vimscript call to a lua function
    local function lua_call(func_call)
        return "<cmd>call v:lua." .. func_call .. "<CR>"
    end

    -- Keymaps are sort of based on the README of nvim-lspconfig

    -- Like ctags Ctrl+], but with <leader>
    -- TODO: Possibly change this to Ctrl+] (and maybe put Ctrl+] in another
    --       keymap) once I feel this can more or less replace ctags
    buf_set_keymap("n", "<leader>]", lua_call("vim.lsp.buf.definition()"))
    -- Show a floating window with information about current symbol
    buf_set_keymap("n", "<leader>h", lua_call("vim.lsp.buf.hover()"))
    -- Show the diagnostic message for the current line (in case it's too long
    -- to be displayed fully)
    buf_set_keymap("n", "<leader>d",
                   lua_call("vim.lsp.diagnostic.show_line_diagnostics()"))
    -- Navigate between diagnostic messages
    buf_set_keymap("n", "[d", lua_call("vim.lsp.diagnostic.goto_prev()"))
    buf_set_keymap("n", "]d", lua_call("vim.lsp.diagnostic.goto_next()"))

    -- Use lsp omnifunc for Ctrl+N, and move normal Ctrl+N completion to
    -- Ctrl+X,Ctrl+N

    function M.ctrl_n()
        -- This is needed so when we're in the middle of a "normal" Ctrl+N
        -- (i.e. performed via Ctrl+X,Ctrl+N) and we press Ctrl+N, it will
        -- continue with the normal one and not use the omnifunc
        local result = (vim.fn.pumvisible() == 1 and "<c-n>" or
                        lua_call("vim.lsp.omnifunc(1)"))
        return vim.api.nvim_replace_termcodes(result, true, true, true)
    end

    buf_set_keymap("i", "<c-n>", "v:lua.lsp_setup.ctrl_n()", { expr = true })
    buf_set_keymap("i", "<c-x><c-n>", "<c-n>")
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

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Disable diagnostics signs (which add a column at the left of a
        -- buffer)
        signs = false,
        -- Don't update diagnostics in insert mode
        update_in_insert = false
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
