-- All configuration related to the core text editing part of neovim


local utils = require("config.utils")


--
-- Indentation/whitespace
--

-- Tab settings
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- Repeatedly use > and < to indent in visual mode
utils.set_keymap("v", "<", "<gv")
utils.set_keymap("v", ">", ">gv")

-- When moving indentation (< and > in visual mode) always round to the nearest
-- tabstop
vim.o.shiftround = true

-- Display invisible characters
vim.o.list = true
vim.opt.listchars = {
    -- Display tabs as >---
    tab = ">-",
    -- Show trailing spaces
    trail = "░",
    -- When 'wrap' is off, display > or < to indicate there is something there
    extends = ">",
    precedes = "<"
}


--
-- Character limit per line
--

-- Ideally each line should have <80 characters
vim.o.textwidth = 79

-- Color the last valid column
vim.o.colorcolumn = tostring(vim.o.textwidth)

-- Only auto-format comments with textwidth, not code
vim.opt.formatoptions:remove("t")
vim.opt.formatoptions:append("c")
-- But auto-format everything for text/markdown
vim.api.nvim_create_autocmd("FileType", {
    pattern = "text,markdown",
    callback = function() vim.opt_local.formatoptions:append("t") end
})

-- When entering a new line according to textwidth, try to indent a bit to
-- match lists
vim.opt.formatoptions:append("n")


--
-- Line wrapping (when a line is too long to fit)
--

-- When wrapping an indented line, indent the rest of it the same
vim.o.breakindent = true

-- Do not break in the middle of a word when wrapping
vim.o.linebreak = true

-- Use j and k even on the same (wrapped) line, but not when navigating to a
-- specific line with a number
for _, mode in ipairs({"n", "x"}) do
    utils.set_keymap(mode, "j", "v:count == 0 ? 'gj' : 'j'", true)
    utils.set_keymap(mode, "k", "v:count == 0 ? 'gk' : 'k'", true)
end


--
-- Keymaps for text editing
--

-- Map Ctrl+j/k to add new lines without going to insert mode
utils.set_keymap("n", "<C-j>", "o<Esc>")
utils.set_keymap("n", "<C-k>", "O<Esc>")

-- Map Alt+j to add a <CR> without going to insert mode
utils.set_keymap("n", "<M-j>", "a<CR><Esc>")


--
-- Misc
--

-- Highlight current line
vim.o.cursorline = true

-- Turn line numbers on
vim.o.number = true
-- Other than current line, show numbers relative to current line (for easier
-- [number]j/k)
vim.o.relativenumber = true

-- Smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Display the effect of text substitution live
vim.o.inccommand = "split"

-- Always show complete menu, even if has only one option
vim.o.completeopt = "menuone"

-- By default fold according to syntax
vim.o.foldmethod = "syntax"
-- But don't actually fold anything unless foldlevel is set
vim.o.foldlevelstart = 99

-- By default, treat .h files as C files (not C++)
vim.g.c_syntax_for_h = 1
