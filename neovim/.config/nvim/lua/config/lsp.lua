local M = {}

local lspconfig = require('lspconfig')
local fzf_lua = require('fzf-lua')
local colors = require("config.colors")
local utils = require("config.utils")

M.clangd = {
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

M.lua_ls = {
    settings = { Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
                vim.env.VIMRUNTIME,
                -- And also of the third party luv library
                "${3rd}/luv/library"
            },
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
    lspconfig.pyright.setup({})
    lspconfig.ruff.setup({})
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
    virtual_text = { source = true },
    float = {
        source = true,
        -- Can't move the cursor to inside the floating window
        focusable = false,
        -- Hide the floating window pretty much when anything happens
        close_events = { "BufLeave", "CursorMoved", "InsertEnter",
                         "FocusLost" }
    },
    jump = {
        -- Open the diagnostic floating window when jumping into one
        float = true,
        -- Don't wrap around when jumping between diagnostics
        wrap = false
    }
})

-- Set LSP related settings only after a language server is attached
vim.api.nvim_create_autocmd("LspAttach", { callback = function(args)
    -- Remove neovim default LSP mapping of K to hover, already using <leader>h
    vim.keymap.del("n", "K", { buffer = args.buf })

    -- Keymaps in normal mode
    utils.which_key_register({
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
        -- Remap the default diganoistics navigation keymaps to not wrap
        ["[d"] = { function() vim.diagnostic.jump({ count = -1 }) end,
                   "Prev diagnostic" },
        ["]d"] = { function() vim.diagnostic.jump({ count = 1 }) end,
                   "Next diagnostic" },
        -- Navigate only between error diagnostic messages
        ["[D"] = {
            function() vim.diagnostic.jump({
                count = -1, severity = vim.diagnostic.severity.ERROR
            }) end,
            "Prev error diagnostic"
        },
        ["]D"] = {
            function() vim.diagnostic.jump({
                count = 1, severity = vim.diagnostic.severity.ERROR
            }) end,
            "Next error diagnostic"
        },

        -- FZF keymaps
        -- Note that the tags keybindings are overwriting the existing ones
        -- that don't use LSP
        ["<leader>t"] = {
            fzf_lua.lsp_document_symbols,
            "Fuzzy search current buffer symbols"
        },
        ["<leader>T"] = {
            fzf_lua.lsp_live_workspace_symbols,
            "Fuzzy search project symbols"
        },
        ["<leader>l"] = { fzf_lua.lsp_references, "Fuzzy search references" }
    }, { buffer = args.buf })

    -- Keymaps in insert mode
    utils.which_key_register({
        -- Use the omnifunc for Ctrl+N
        ["<c-n>"] = { function ()
            -- This hack is needed so when we're in the middle of a "normal"
            -- Ctrl+N (i.e. performed via Ctrl+X,Ctrl+N) and we press Ctrl+N,
            -- it will continue with the normal one and not use the omnifunc
            if vim.fn.pumvisible() == 1 then
                vim.api.nvim_input("<c-x><c-n>")
            else
                vim.lsp.omnifunc(1, 0)
            end
        end, "LSP omnifunc complete" },

        -- Use the "regular" Ctrl+N with Ctrl+X,Ctrl+N
        ["<c-x><c-n>"] = { "<c-n>", "Regular Ctrl+N" }
    }, {mode = "i", buffer = args.buf })
end, })

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

-- Hide all semantic highlights set by LSP servers
-- At the moment I am still not ready to adopt this. First it changes a bit the
-- colors from what I am used to and second it overwrites todo marks (e.g. TODO
-- or XXX). For the colors I guess eventually I should just adapt my
-- colorscheme to these highlights (as well as obviously treesitter
-- eventually). For todo I should either use a plugin that highlights these
-- stuff or put the todo mark as higher priority.
-- More info: :help lsp-semantic-highlight
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
end

return M
