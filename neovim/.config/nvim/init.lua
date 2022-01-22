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
    -- use("w0ng/vim-hybrid")
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

    -- Use j and k even on the same line
    ["j"] = { "gj", "which_key_ignore" },
    ["k"] = { "gk", "which_key_ignore" },

    -- Also copy file name on Ctrl+G
    ["<C-g>"] = { "<cmd>let @+ = expand('%')<CR><C-g>", "which_key_ignore" }
})

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

-- Allow choosing from the whole 24bit color range
vim.o.termguicolors = true

-- Set the colorscheme to dark hybrid
vim.cmd("colorscheme hybrid")
vim.o.background = "dark"

-- Don't use theme background, but rather terminal background
vim.cmd("highlight Normal guibg=NONE")

-- Turn line numbers on
vim.o.number = true

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

--  When wrapping an indented line, indent the rest of it the same
vim.o.breakindent = true

-- Smart case search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight current line
vim.o.cursorline = true

-- Display the effect of text substitution live
vim.o.inccommand = "split"

-- Always show complete menu, even if has only one option
vim.o.completeopt = "menuone"


-- Load all separate config files
require("config.buffers")
require("config.lsp").setup()
require("config.statusline")
require("config.bufferline")
require("config.fzf")


-- Include a file describing projects-specific configs (for nvim-projectconfig)
-- if exists
-- This is done last in order to overwrite previous settings
pcall(require, 'projects')
