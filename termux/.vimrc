set nu
set hlsearch
set cursorline
set ts=4
set shiftwidth=4
set autoindent
set incsearch
set ignorecase
set smartcase

call plug#begin()
Plug 'JBakamovic/yaflandia'
Plug 'scrooloose/syntastic'
Plug 'ajh17/vimcompletesme'
Plug 'mattesgroeger/vim-bookmarks'
Plug 'scrooloose/nerdtree'
Plug 'craigemery/vim-autotag'
Plug 'brookhong/cscope.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'MattesGroeger/vim-bookmarks'
call plug#end()

nmap > : vertical res +1<CR>
nmap < : vertical res -1<CR>
"map <C-K> : call SyntasticReset()<CR>
nmap <leader>s : %!astyle<CR>


" CSCOPE
let g:cscope_silent = 1
let g:cscope_auto_update = 1
nnoremap fa :call CscopeFindInteractive(expand('<cword>'))<CR>
nnoremap <leader>f :call ToggleLocationList()<CR>

" taglist
nmap <C-L> : Tlist<CR> : TlistUpdate<CR>
let g:Tlist_Show_One_File = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_Close_On_Select = 1
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Auto_Update = 0
let g:Tlist_Auto_Highlight_Tag = 1

" NERDTree
nmap <C-K> : NERDTreeToggleVCS<CR>

" syntastic
nmap <C-I> : SyntasticCheck<CR>
nmap <C-O> : Error<CR>
nmap <C-P> : lclose<CR>
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_loc_list_height = 3

" ctags
set tags+=.tags;/
set tags+=tags;/
set autochdir
let g:autotagTagsFile=".tags"
nmap . : tn<CR>
nmap , : ts<CR>

"BookmarkToggle
let g:bookmark_auto_save = 1
let g:bookmark_sign = '♥'
let g:bookmark_highlight_lines = 1

