-- Fancy function to look for lazy.nvim in multiple locations, and even
-- possibly clone it if needed
local get_lazy = function()
    -- First check if we can simply require "lazy". This is for the
    -- possible scenario where lazy.nvim is installed as a system package.
    local is_lazy_installed, lazy = pcall(require, "lazy")
    if is_lazy_installed then
        return lazy
    end

    -- We couldn't just require it, so let's see if lazy.nvim exists in the
    -- neovim directory
    local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.uv.fs_stat(lazy_path) then
        -- We couldn't find lazy.nvim anywhere. Before immediately doing a git
        -- clone, ask the user.
        local response = vim.fn.input("lazy.nvim plugin manager not found\n" ..
                                      "Clone it from GitHub? [y/n]: ")
        if response ~= "y" then
            return nil
        end

        -- User agreed, clone lazy.nvim
        vim.fn.system({ "git", "clone",
                        "https://github.com/folke/lazy.nvim.git",
                        "--branch=stable", lazy_path })
    end

    -- Load lazy.nvim from the neovim directory
    vim.opt.rtp:prepend(lazy_path)
    return require("lazy")
end

local lazy = get_lazy()
if not lazy then
    -- This config file is too dependant on plugins to work without them
    os.exit()
end

-- Map space to <leader>
-- Need to set this first as the winresizer plugin config depends on it
vim.g.mapleader = " "

-- Setup lazy.nvim plugin manager
lazy.setup(
    -- Plugins
    {
        "lzap/vim-selinux",
        "moll/vim-bbye",
        -- Annoyingly the way winresizer sets keybinding ends up setting the
        -- default before being able to read our configured one, load it lazily
        -- only after the keybinding is pressed
        { "simeji/winresizer", keys = "<leader>r" },
        "simnalamburt/vim-mundo",
        "windwp/nvim-projectconfig",
        "folke/which-key.nvim",
        "ibhagwan/fzf-lua",
        "nvim-lualine/lualine.nvim",
        { "noib3/nvim-cokeline", dependencies = { "nvim-lua/plenary.nvim" } },
        "Pocco81/TrueZen.nvim",
        -- Plugins available as Arch packages:
        -- "tpope/vim-fugitive",
        -- "tpope/vim-rhubarb",
        -- "neovim/nvim-lspconfig",
    },
    {
        -- Clone full repository, makes it easier to debug plugins code
        git = { filter = false },
        performance = {
            -- Don't reset pathes, we want to use system packages as well
            reset_packpath = false,
            rtp = { reset = false,
                    -- Disable netrw, to disable accidentally opening it by
                    -- opening a directory
                    disabled_plugins = { "netrwPlugin" }
            }
        }
    }
)

local utils = require("config.utils")
local which_key = require("which-key")

-- Replace ; and :
utils.set_keymap("n", ";", ":", false, true)
utils.set_keymap("n", ":", ";", false, true)

-- Exit input mode with Ctrl+c
utils.set_keymap("i", "<C-c>", "<Esc>")

-- Also copy file name on Ctrl+G
utils.set_keymap("n", "<C-g>", "<cmd>let @+ = expand('%')<CR><C-g>")

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

-- By default neovim only expects sway syntax in sway/config, so add also
-- sway/*.conf
vim.filetype.add({pattern = { ['.*/sway/.+%.conf'] = 'swayconfig' } })

-- These providers are not used
vim.g.loaded_python_provider = 0 -- This is python 2
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- If inside a virtualenv, still use the main system python
if os.getenv("VIRTUAL_ENV") then
    local cmd = "which -a python3 | head -n2 | tail -n1"
    vim.g.python3_host_prog = vim.fn.system(cmd):gsub("\n", "")
end

-- Git keymaps
which_key.add({ "<leader>g", group = "Git" })
utils.which_key_register({
    b = { "<cmd>G blame<CR>", "Git blame" },
    d = { "<cmd>Gdiff<CR>", "Git diff" }
}, { prefix = "<leader>g" })

-- In visual mode only browse is an option, so can just use <leader>g
which_key.add({ "<leader>g", "<esc><cmd>'<,'>GBrowse!<CR>",
                desc = "Git browse - copy link to selection", mode = "x" })

-- Load all separate config files
require("config.colorscheme")
require("config.text_editing")
require("config.buffers")
require("config.fzf")
-- LSP needs to be after FZF as it can overwrite some keybindigs
require("config.lsp").setup()
require("config.statusline")
require("config.bufferline")
require("config.which_key")


-- Include a file describing projects-specific configs (for nvim-projectconfig)
-- if exists
-- This is done last in order to overwrite previous settings
pcall(require, 'projects')
