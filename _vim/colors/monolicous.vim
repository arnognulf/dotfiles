" Vim color file
" Maintainer:	Thomas Eriksson <thomas.eriksson@gmail.com>
" URL:		http://github.com/arnognulf/monolicous
" Version:	1.0

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
	hi clear
endif
let g:colors_name="monolicous"

set t_Co=0

hi Comment	NONE
hi Constant	NONE
hi CursorIM 	NONE
hi Cursor		NONE
hi DiffAdd 		NONE
hi DiffChange	NONE
hi DiffDelete	NONE
hi DiffText		NONE
hi Directory 	NONE
hi ErrorMsg		term=reverse,bold
hi Error		term=reverse
hi FoldColumn	NONE
hi Folded		NONE
hi Identifier	NONE
hi Ignore		NONE
hi IncSearch	term=reverse,bold,underline
hi LineNr		NONE
hi Menu			term=reverse
" following only works when t_Co is > 8. boo!
hi MatchParen	term=bold,underline
hi ModeMsg		NONE
hi NonText		NONE
hi Normal		NONE
hi PreProc		NONE
hi Question		NONE
hi Scrollbar 	NONE
hi Search		term=reverse
hi SpecialKey	NONE
hi Special		NONE
hi Statement 	NONE
hi StatusLineNC NONE
hi StatusLineNC	NONE
hi StatusLine	NONE
hi TabLine		term=underline
hi TabLineFill	NONE
hi TabLineSel	NONE
hi Title		NONE
hi Todo			term=reverse,bold
hi Tooltip		NONE
hi Type			NONE
hi Underlined 	NONE
hi VertSplit	NONE
hi VisualNOS 	term=reverse
hi Visual		term=reverse
hi WarningMsg	NONE
hi WildMenu		NONE

"vim: sw=4
