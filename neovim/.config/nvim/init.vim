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
    use("nvim-lua/lsp-status.nvim")
    use("folke/which-key.nvim")
    -- Plugins available as Arch packages:
    -- use("w0ng/vim-hybrid")
    -- use("vim-airline/vim-airline")
    -- use("vim-airline/vim-airline-themes")
    -- use("tpope/vim-fugitive")
    -- use("junegunn/fzf")
    -- use("junegunn/fzf.vim")
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


"""""""""""""""""""""
" Buffers & Windows "
"""""""""""""""""""""

" Allow hidden buffers that weren't saved.
set hidden

" Display the current buffers with Airline.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_min_count = 2

" Go to a buffer based on its index using <leader>*index*.
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

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

" Detect file types and indent them accordingly.
filetype indent on

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

" Color text based on the file type.
syntax on

" Set the colorscheme to dark hybrid.
colorscheme hybrid
set background=dark
" Don't use theme background, but rather terminal background.
highlight Normal ctermbg=NONE

" Turn line numbers on.
set number

" Add a column at 80 characters.
set colorcolumn=79

" Display invisible characters.
set list
" Configure 'list' to properly display only trailing invisible characters.
let &listchars = "tab:>-,trail:\u2591,extends:>,precedes:<,nbsp:\u00b7"

" Tell airline to use Powerline fonts, only if using a capable terminal.
let g:airline_powerline_fonts = $TERM =~ "xterm"

" Create airline parts for LSP status info
call airline#parts#define_function('lsp_progress', 'v:lua.lsp_setup.status_progress')
call airline#parts#define_function('lsp_diagnostics', 'v:lua.lsp_setup.status_diagnostics')
call airline#parts#define_accent('lsp_diagnostics', 'bold')

" Move filetype to section y, remove file encoding and put LSP status info
let g:airline_section_x = airline#section#create_right(['lsp_diagnostics', 'lsp_progress'])
let g:airline_section_y = airline#section#create_right(['filetype'])

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

" Tab settings.
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
" Disable python's defaults so they don't overwrite our tab settings.
let g:python_recommended_style = 0

" Smart case search.
set ignorecase
set smartcase

" Don't highlight searches.
set nohlsearch

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
lua require('lsp_setup').setup()


"""""""
" FZF "
"""""""

" By default the FZF window should be on the entire screen
let g:fzf_layout = {'down': '100%'}

" Setup :FromIndex
" Like :FZF, but uses an file index as list of possible files to open
" File index path is stored in g:index_file, which by default is 'files'
" The idea is kind of like tags file
let g:index_file = "files"
function! s:from_index()
    if !filereadable(g:index_file)
        echoerr "Couldn't find file '" . g:index_file . "'"
        return
    endif
    call fzf#vim#files("", {"source": "cat " . g:index_file})
endfunction
command! FromIndex call s:from_index()

function! s:ag_index(query)
    if !filereadable(g:index_file)
        echoerr "Couldn't find file '" . g:index_file . "'"
        return
    endif
    call fzf#vim#grep("xargs -a " . g:index_file . " -d '\\n' ag --nogroup --column --color " . a:query, 0)
endfunction
command! -nargs=+ AgIndex call s:ag_index(<q-args>)

command! -bang -complete=dir -nargs=+ Ag call fzf#vim#ag_raw(<q-args>, <bang>-1)

" Shortcuts for different FZF commands
nnoremap <leader>e :Files<CR>
nnoremap <leader>f :FromIndex<CR>
nnoremap <leader>t :BTags<CR>
nnoremap <leader>T :Tags<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>; :History:<CR>
nnoremap <leader>/ :History/<CR>
nnoremap <leader>a :Ag -w <cword><CR>



" Include a file describing projects-specific configs (for nvim-projectconfig)
" if exists
" This is done last in order to overwrite previous settings
lua pcall(require, 'projects')
