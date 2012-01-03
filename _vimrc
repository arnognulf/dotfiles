map 1 :tabn 1<CR>
map 2 :tabn 2<CR>
map 3 :tabn 3<CR>
map 4 :tabn 4<CR>
map 5 :tabn 5<CR>
map 6 :tabn 6<CR>
map 7 :tabn 7<CR>
map 8 :tabn 8<CR>
map 9 :tabn 9<CR>
map 0 :tabn 10<CR>

set listchars=tab:>-,eol:$,trail:.,extends:#
" toggle show newlines, blanks and tabs
map <F4> :set list! list?<CR>

set nocompatible
set autoindent
set smartindent
set ignorecase
set smartcase
set showmatch
set guioptions-=T
set vb t_vb=
set incsearch
set ruler
set title
set number
set title
set hlsearch
set wrap
set backspace=indent,eol,start
" remove highlight from search
nmap <SPACE> <SPACE>:noh<CR>
set softtabstop=4 shiftwidth=4 expandtab
hi Tab gui=underline guifg=blue ctermbg=blue term=reverse

source $HOME/.vimrc_local
colorscheme monolicous
if has("autocmd")
" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\   exe "normal g'\"" |
\ endif
endif

filetype on
filetype plugin on
filetype indent on

