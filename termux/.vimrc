set nu
set hlsearch
set cursorline
set ts=4
set shiftwidth=4
set autoindent

call plug#begin()
Plug 'JBakamovic/yaflandia'
Plug 'scrooloose/syntastic'
Plug 'ajh17/vimcompletesme'
Plug 'mattesgroeger/vim-bookmarks'
Plug 'scrooloose/nerdtree'
Plug 'craigemery/vim-autotag'
Plug 'brookhong/cscope.vim'
Plug 'vim-scripts/taglist.vim'
call plug#end()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:cscope_silent = 1

" CSCOPE
nnoremap fa :call CscopeFindInteractive(expand('<cword>'))<CR>
nnoremap <leader>f :call ToggleLocationList()<CR>

nmap > : vertical res +1<CR>
nmap < : vertical res -1<CR>
nmap <C-L> : Tlist<CR> call SyntasticReset()<CR>
nmap <leader>s : %!astyle<CR>


