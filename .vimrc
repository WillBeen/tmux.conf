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
