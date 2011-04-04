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
    "See help statusline (I toggle between 12 helpful rulers -- more on that later)
fu ShowTab()
    let TabLevel = (indent('.') / &ts )
    if TabLevel == 0
    let TabLevel='*'
    endif
    return TabLevel
    endf
    "The ruler (statusline) shows a t* unless you are on col 1,5,9,13,...
set laststatus=2
    "This makes sure the ruler shows. See help laststatus
set statusline=\ \ \ \ ┃╷╷╷╷╻╷╷╷╷1╷╷╷╷╻╷╷╷╷2╷╷╷╷╻╷╷╷╷3╷╷╷╷╻╷╷╷╷┃╷╷╷╷╻╷╷╷╷5╷╷╷╷╻╷╷╷╷6╷╷╷╷╻╷╷╷╷7╷╷╷╷╻╷╷╷╷┃╷╷╷╷╻╷╷╷╷9╷╷╷╷╻╷╷╷10╷╷╷╷╻╷╷╷11╷╷╷╷╻╷╷╷╷┃╷╷╷╷╻╷╷╷12╷╷╷╷╻╷╷╷13╷╷╷╷╻╷╷╷14╷╷╷╷╻╷╷╷╷┃\ \ 



    map <F2> :call RulerStr()<NL>0P

function! RulerStr()
    let columns = &columns
    let inc = 0
    let str = ""
while (inc < columns)
    let inc10 = inc / 10 + 1
    let buffer = "."
if (inc10 > 9)
    let buffer = ""
    endif
    let str = str . "....+..." . buffer . inc10
    let inc = inc + 10
    endwhile
let str = strpart(str, 0, columns)
    let @@ = str
    endfunction


    "set statusline=\ \ \ \ \|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|....:....\|..

    "....+....|
    " ....+....|....+....|....+....|....+....|....+....|....+....|....+....|
    "\ %{ShowTab()}
    " %f\ ---------\ My\ Ruler\ ----------\ r%l,c%c,t%{ShowTab()}

filetype on
filetype plugin on
filetype indent on

