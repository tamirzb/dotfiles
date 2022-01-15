"""""""""""
" Plugins "
"""""""""""

lua << EOF

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

EOF


"""""""""""
" General "
"""""""""""

" Replace ; and :
nnoremap ; :
nnoremap : ;

" Map space to <leader>.
let g:mapleader = " "

" Enable using the mouse to control things
set mouse=a

lua require('config.fzf')


"""""""""""""""""""""
" Buffers & Windows "
"""""""""""""""""""""

" Allow hidden buffers that weren't saved.
set hidden

" Use Ctrl+e to delete a buffer without closing the window
nnoremap <C-w>e :Bwipeout<CR>
nnoremap <C-w><C-e> :Bwipeout<CR>

" Enter winresizer with <leader>r
let g:winresizer_start_key = "<leader>r"
" Exit winresizer with r
let g:winresizer_keycode_finish = 114
" The default to change to resize mode is r, so change it to Shift+r
let g:winresizer_keycode_resize = 82

"""""""""""""""""""
" File management "
"""""""""""""""""""

" By default, treat .h files as C files (not C++)
let g:c_syntax_for_h = 1

" Remember 1000 files in v:oldfiles.
set shada=!,'1000,<50,s10,h

" Save undo history in files to be available even after closing neovim
set undofile
" Save up to 10000 undos per file
set undolevels=10000


""""""""""""""
" Appearance "
""""""""""""""

set termguicolors
" Set the colorscheme to dark hybrid.
colorscheme hybrid
set background=dark
" Don't use theme background, but rather terminal background.
highlight Normal guibg=NONE

" Turn line numbers on.
set number

" Add a column at 80 characters.
set colorcolumn=79

" Display invisible characters.
set list
" Configure 'list' to properly display only trailing invisible characters.
let &listchars = "tab:>-,trail:\u2591,extends:>,precedes:<,nbsp:\u00b7"

lua require('config.statusline')

lua require('config.bufferline')


""""""""""""""""
" Text editing "
""""""""""""""""

" Exit input mode with Ctrl+c.
inoremap <C-c> <Esc>

" Repeatedly use > and < to indent in visual mode.
vnoremap < <gv
vnoremap > >gv

" Map Ctrl+j/k to add new lines without going to insert mode.
nnoremap <C-j> o<Esc>
nnoremap <C-k> O<Esc>

" Map Alt+j to add a <CR> without going to insert mode
nnoremap <M-j> a<CR><Esc>

" Tab settings.
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
" When wrapping an indented line, indent the rest of it the same
set breakindent

" Smart case search.
set ignorecase
set smartcase

" Highlight current line.
set cursorline

" Display the effect of text substitution live.
set inccommand=split

" Use j and k even on the same line.
nnoremap j gj
nnoremap k gk

" Always show complete menu, even if has only one option
set completeopt=menuone

" Setup language servers
lua require('config.lsp').setup()



" Include a file describing projects-specific configs (for nvim-projectconfig)
" if exists
" This is done last in order to overwrite previous settings
lua pcall(require, 'projects')
