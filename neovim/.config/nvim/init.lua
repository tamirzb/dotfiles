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

local utils = require("config.utils")
local which_key = require("which-key")

-- Replace ; and :
utils.set_keymap("n", ";", ":", false, true)
utils.set_keymap("n", ":", ";", false, true)

-- Exit input mode with Ctrl+c
utils.set_keymap("i", "<C-c>", "<Esc>")

-- Also copy file name on Ctrl+G
utils.set_keymap("n", "<C-g>", "<cmd>let @+ = expand('%')<CR><C-g>")

-- Map space to <leader>
vim.g.mapleader = " "

-- Enable using the mouse to control things
vim.o.mouse = "a"

-- Save undo history in files to be available even after closing neovim
vim.o.undofile = true
-- Save up to 10000 undos per file
vim.o.undolevels = 10000

-- For commands, on the first tab just show a menu, selecting an option only on
-- the second tab
vim.o.wildmode = "longest:full,full"

-- When navigating to different parts in the file (Ctrl+{U,D}, gg, G, etc),
-- move to the start of the line
vim.o.startofline = true

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
require("config.text_editing")
require("config.buffers")
require("config.lsp").setup()
require("config.statusline")
require("config.bufferline")
require("config.fzf")
require("config.which_key")


-- Include a file describing projects-specific configs (for nvim-projectconfig)
-- if exists
-- This is done last in order to overwrite previous settings
pcall(require, 'projects')
