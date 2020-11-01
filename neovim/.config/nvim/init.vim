"""""""""""
" Plugins "
"""""""""""

" Plugins are installed using vim-plug. To install vim-plug run:
"   curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
"   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin()
Plug 'dag/vim-fish'
Plug 'terminalnode/sway-vim-syntax'
Plug 'lzap/vim-selinux'
"" Plugins available as Arch packages:
"Plug 'w0ng/vim-hybrid'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"Plug 'tpope/vim-fugitive'
"Plug 'junegunn/fzf.vim'
call plug#end()


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

" Use Ctrl+e to delete a buffer without closing the window
nnoremap <C-w>e :b#\|bd#<CR>
nnoremap <C-w><C-e> :b#\|bd#<CR>


"""""""""""""""""""
" File management "
"""""""""""""""""""

" Detect file types and indent them accordingly.
filetype indent on

" Remember 1000 files in v:oldfiles.
set shada=!,'1000,<50,s10,h

" Read .exrc files for project specific settings
set exrc
set secure


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
nnoremap <leader>l :Lines<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>h :History<CR>
nnoremap <leader>; :History:<CR>
nnoremap <leader>/ :History/<CR>
