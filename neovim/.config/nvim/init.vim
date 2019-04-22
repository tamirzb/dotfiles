"""""""""""
" Plugins "
"""""""""""

call plug#begin()
Plug 'w0ng/vim-hybrid'
Plug 'dag/vim-fish'
"" Plugins available as Arch packages:
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Plug 'tpope/vim-fugitive'
call plug#end()

" Load installed vim packages.
set rtp^=/usr/share/vim/vimfiles/


"""""""""""
" General "
"""""""""""

" Replace ; and :
nnoremap ; :
nnoremap : ;

" Map space to <leader>.
nmap <space> <leader>


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


"""""""""""""""""""
" File management "
"""""""""""""""""""

" Detect file types and indent them accordingly.
filetype indent on


""""""""""""""
" Appearance "
""""""""""""""

" Set the colorscheme to dark hybrid.
colorscheme hybrid
set background=dark

" Color text based on the file type.
syntax on

" Turn line numbers on.
set number

" Add a column at 100 characters.
set colorcolumn=99

" Display invisible characters.
set list
" Configure 'list' to properly display only trailing invisible characters.
let &listchars = "tab:>-,trail:\u2591,extends:>,precedes:<,nbsp:\u00b7"

" Tell airline to use Powerline fonts.
let g:airline_powerline_fonts = 1


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

" Smart case search.
set ignorecase
set smartcase

" Don't highlight searches.
set nohlsearch

" Highlight current line.
set cursorline

" Use j and k even on the same line.
nnoremap j gj
nnoremap k gk
