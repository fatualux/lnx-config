let g:indentLine_setColors = 0
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:solarized_termcolors=256
set t_Co=256
let g:solarized_contrast="high"
let g:solarized_visibility="high"
set background=dark

" Disable Background Color Erase (BCE) so that color schemes
" render properly when inside 256-color tmux and GNU screen.
if &term =~ '256color'
    set t_ut=
endif
