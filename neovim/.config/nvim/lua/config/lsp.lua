local M = {}

local lspconfig = require('lspconfig')
local which_key = require('which-key')
local fzf_lua = require('fzf-lua')
local colors = require("config.colors")

-- Set LSP related settings only after a language server is attached
local on_attach = function(_, bufnr)
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
        },

        -- FZF keymaps
        -- The opts here are needed to hide the file for fzf-lua LSP providers
        ["<leader>t"] = {
            function()
                fzf_lua.lsp_document_symbols({
                    fzf_opts = { ["--with-nth"] = '4..',
                                 ["--delimiter"] = ":" }
                })
            end,
            "Fuzzy search current buffer symbols"
        },
        ["<leader>T"] = {
            function()
                fzf_lua.lsp_live_workspace_symbols({
                    fzf_opts = { ["--with-nth"] = '4..',
                                 ["--delimiter"] = ":" }
                })
            end,
            "Fuzzy search project symbols"
        },
        ["<leader>l"] = { fzf_lua.lsp_references, "Fuzzy search references" }
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

-- Make the language server recognize the lua libraries
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

M.lua_ls = {
    on_attach = on_attach,
    cmd = { "lua-language-server" },
    -- The settings are pretty much copied from nvim-lspconfig's documentation
    settings = { Lua = {
        runtime = { version = 'LuaJIT', path = runtime_path },
        -- Get the language server to recognize the `vim` global
        diagnostics = { globals = {'vim'} },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
            -- Don't automatically try to load support for 3rd party libraries
            checkThirdParty = false
        },
        -- Do not send telemetry data containing a randomized but unique
        -- identifier
        telemetry = { enable = false },
    } }
}

-- Setup all language servers
function M.setup()
    lspconfig.clangd.setup(M.clangd)
    lspconfig.lua_ls.setup(M.lua_ls)
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

-- Set LSP colors
require("config.utils").apply_highlights({
    DiagnosticError = { fg = colors.error },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInformation = { fg = colors.paleblue },
    DiagnosticHint = { fg = colors.purple },
    DiagnosticVirtualTextError = { fg = colors.error },
    DiagnosticFloatingError = { fg = colors.error },
    DiagnosticSignError = { fg = colors.error },
    DiagnosticUnderlineError = { style = "underline", sp = colors.error },
    DiagnosticVirtualTextWarn = { fg = colors.yellow },
    DiagnosticFloatingWarn = { fg = colors.yellow },
    DiagnosticSignWarn = { fg = colors.yellow },
    DiagnosticUnderlineWarn = { style = "underline", sp = colors.yellow },
    DiagnosticVirtualTextInfo = { fg = colors.paleblue },
    DiagnosticFloatingInfo = { fg = colors.paleblue },
    DiagnosticSignInfo = { fg = colors.paleblue },
    DiagnosticUnderlineInfo = { style = "underline", sp = colors.paleblue },
    DiagnosticVirtualTextHint = { fg = colors.purple },
    DiagnosticFloatingHint = { fg = colors.purple },
    DiagnosticSignHint = { fg = colors.purple },
    DiagnosticUnderlineHint = { style = "underline", sp = colors.purple },
    LspReferenceText = { fg = colors.title, style = "underline" },
    LspReferenceRead = { fg = colors.title, style = "underline" },
    LspReferenceWrite = { fg = colors.title, style = "underline" },
})

return M
