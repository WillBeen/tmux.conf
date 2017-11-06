:set nu
:set autoindent
:syntax on
if &term == "screen"
  set t_Co=256
endif
colorscheme torte
:set showmode
highlight Normal ctermbg=NONE
highlight LineNr ctermfg=245 ctermbg=235
let g:airline_powerline_fonts = 1
let g:airline_theme='badwolf'
