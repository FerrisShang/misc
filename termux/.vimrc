set nu
set hlsearch
set cursorline
set ts=4
set shiftwidth=4
set autoindent

call plug#begin()
Plug 'JBakamovic/yaflandia'
call plug#end()

execute pathogen#infect()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
