-- Install packer if it's not already installed
-- TODO: Run packer.sync() automatically
local was_packer_installed, packer = pcall(require, "packer")
if not was_packer_installed then
    print("Installing packer...")
    vim.fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim",
                   vim.fn.stdpath("data") ..
                   "/site/pack/packer/start/packer.nvim"})
    print("Packer installed")
    packer = require("packer")
end

-- Plugins
packer.startup({ function (use)
    use("wbthomason/packer.nvim")
    use("dag/vim-fish")
    use("terminalnode/sway-vim-syntax")
    use("lzap/vim-selinux")
    use("moll/vim-bbye")
    use("simeji/winresizer")
    use("simnalamburt/vim-mundo")
    use("windwp/nvim-projectconfig")
    use("folke/which-key.nvim")
    use("ibhagwan/fzf-lua")
    use("nvim-lualine/lualine.nvim")
    use("arkav/lualine-lsp-progress")
    use('noib3/nvim-cokeline')
    -- Plugins available as Arch packages:
    -- use("tpope/vim-fugitive")
    -- use("neovim/nvim-lspconfig")
    -- use("cespare/vim-toml")
end, config = {
    -- Clone with full history, makes it easier to debug plugins code
    git = { depth = 999999 } }
})

-- Configure which-key, a plugin that will show help when stuck in the middle
-- of a keymap
local which_key = require("which-key")
which_key.setup({
    -- Use which-key for spelling corrections (with z=)
    plugins = { spelling = true },
    -- Adding count to motions (e.g. d2) seems to be displaying which-key
    -- immediately, so better without it
    motions = { count = false }
})

-- The following keymaps for some reason don't work well with which-key

-- Replace ; and :
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })
vim.api.nvim_set_keymap("n", ":", ";", { noremap = true })

-- Exit input mode with Ctrl+c
vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = true })

-- Repeatedly use > and < to indent in visual mode
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true })

which_key.register({
    -- Map Ctrl+j/k to add new lines without going to insert mode
    ["<C-j>"] = { "o<Esc>", "Enter new line below current line" },
    ["<C-k>"] = { "O<Esc>", "Enter new line above current line" },

    -- Map Alt+j to add a <CR> without going to insert mode
    ["<M-j>"] = { "a<CR><Esc>", "Enter <CR>" },

    -- Also copy file name on Ctrl+G
    ["<C-g>"] = { "<cmd>let @+ = expand('%')<CR><C-g>", "which_key_ignore" }
})

-- Use j and k even on the same (wrapped) line, but not when navigating to a
-- specific line with a number
local jk_opts = { noremap = true, expr = true }
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", jk_opts)
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", jk_opts)

-- Map space to <leader>
vim.g.mapleader = " "

-- Enable using the mouse to control things
vim.o.mouse = "a"

-- By default, treat .h files as C files (not C++)
vim.g.c_syntax_for_h = 1

-- Save undo history in files to be available even after closing neovim
vim.o.undofile = true
-- Save up to 10000 undos per file
vim.o.undolevels = 10000

-- Turn line numbers on
vim.o.number = true

-- Other than current line, show numbers relative to current line (for easier
-- [number]j/k)
vim.o.relativenumber = true

-- Line width should be <80 characters
vim.o.textwidth = 79
-- Only auto-format comments with textwidth, not code
vim.opt.formatoptions = vim.opt.formatoptions - "t" + "c"
-- But auto-format everything for text/markdown
vim.cmd("au FileType text,markdown setlocal formatoptions+=t")
-- Color the last valid column
vim.o.colorcolumn = tostring(vim.o.textwidth)

-- When entering a new line according to textwidth, try to indent a bit to
-- match lists
vim.opt.formatoptions = vim.opt.formatoptions + "n"

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

-- Tab settings
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop = 4

-- When moving indentation (< and > in visual mode) always round to the nearest
-- tabstop
vim.o.shiftround = true

--  When wrapping an indented line, indent the rest of it the same
vim.o.breakindent = true

-- Do not break in the middle of a word when wrapping
vim.o.linebreak = true

-- Smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight current line
vim.o.cursorline = true

-- Display the effect of text substitution live
vim.o.inccommand = "split"

-- Always show complete menu, even if has only one option
vim.o.completeopt = "menuone"

-- For commands, on the first tab just show a menu, selecting an option only on
-- the second tab
vim.o.wildmode = "longest:full,full"

-- By default fold according to syntax
vim.o.foldmethod = "syntax"
-- But don't actually fold anything unless foldlevel is set
vim.o.foldlevelstart = 99

-- These providers are not used
vim.g.loaded_python_provider = 0 -- This is python 2
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Disable netrw, to disable accidentally opening it by opening a directory
vim.g.loaded_netrwPlugin = 1

-- If inside a virtualenv, still use the main system python
if os.getenv("VIRTUAL_ENV") then
    local cmd = "which -a python3 | head -n2 | tail -n1"
    vim.g.python3_host_prog = vim.fn.system(cmd):gsub("\n", "")
end

-- Load all separate config files
require("config.colorscheme")
require("config.buffers")
require("config.lsp").setup()
require("config.statusline")
require("config.bufferline")
require("config.fzf")


-- Include a file describing projects-specific configs (for nvim-projectconfig)
-- if exists
-- This is done last in order to overwrite previous settings
pcall(require, 'projects')
