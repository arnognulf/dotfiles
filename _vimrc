set nocompatible
set autoindent
set smartindent
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

map <C-F1> 1gt
map <C-F2> 2gt
map <C-F3> 3gt
map <C-F4> 4gt
map <C-F5> 5gt
map <C-F6> 6gt
map <C-F7> 7gt
map <C-F8> 8gt
map <C-F9> 9gt
map <C-F0> 10g
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

