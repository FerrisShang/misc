set nu
set hlsearch
set cursorline
set ts=4
set shiftwidth=4
set autoindent
set incsearch
set ignorecase
set smartcase
set linebreak
set scrolloff=3
set path+=$PWD/**
set encoding=utf-8
set dir=/tmp/

call plug#begin()
Plug 'JBakamovic/yaflandia'
Plug 'scrooloose/syntastic'
Plug 'ajh17/vimcompletesme'
Plug 'scrooloose/nerdtree'
Plug 'brookhong/cscope.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 't9md/vim-quickhl'
Plug 'kien/ctrlp.vim'
call plug#end()

nmap > : vertical res +1<CR>
nmap < : vertical res -1<CR>
nmap <leader>s : %!astyle<CR>
nmap . <CR><C-w>wj<CR>
nmap , <CR><C-w>wk<CR>
let g:netrw_keepdir= 0

let g:save_session = 1
nmap Q : !rm -f .vim-session<CR>:let g:save_session=0<CR>:qa<CR>
function! MakeSession()
	if g:save_session == 1
		exe "mksession! .vim-session"
	endif
endfunction
au VimLeave * :call MakeSession()
if filereadable('.vim-session')
	autocmd VimEnter * if argc()==0|source .vim-session|endif
endif



function! QuickFix_toggle()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			cclose
			file
			return
		endif
	endfor
"	execute 'vert botright copen \| vert resize 200'
	execute "copen \| res ".winheight(0)/2
endfunction

execute "set <M-K>=\eK"
noremap <M-K> : find<Space>
execute "set <M-q>=\eq"
noremap <M-q> : cn<CR>
execute "set <M-w>=\ew"
noremap <M-w> : cp<CR>
execute "set <M-a>=\ea"
noremap <M-a> : call QuickFix_toggle()<CR>
execute "set <M-s>=\es"
noremap <M-s> <C-o>
execute "set <M-d>=\ed"
noremap <M-d> <C-i>
execute "set <M-z>=\ez"
noremap <M-z> #
execute "set <M-x>=\ex"
noremap <M-x> *
execute "set <M-f>=\ef"
noremap <M-f> :grep -r '\b<cword>\b' **/*<CR>
execute "set <M-Q>=\eQ"
noremap <M-Q> : !make clean<CR>
execute "set <M-A>=\eA"
noremap <M-A> : call CscopeDbUpdate()<CR>
execute "set <M-W>=\eW"
noremap <M-W> <C-b>
execute "set <M-S>=\eS"
noremap <M-S> <C-f>
execute "set <M-D>=\eD"
noremap <M-D> : call GdbOutput()<CR>
execute "set <M-E>=\eE"
noremap <M-E> : !make menuconfig<CR>
execute "set <M-C>=\eC"
noremap <M-C> : silent make -j16<CR>:redraw!<CR>: call QuickFix_toggle()<CR>
execute "set <M-Z>=\eZ"
noremap <M-Z> : tabe ~/.gdbinit<CR>
execute "set <M-X>=\eX"
noremap <M-X> : tabe ./.gdbinit.local<CR>
execute "set <M-1>=\e1"
noremap <M-1> [[
execute "set <M-2>=\e2"
noremap <M-2> ]]
execute "set <M-h>=\eh"
noremap <M-h> : call SwitchExt()<CR>
execute "set <M-l>=\el"
imap <M-l> <C-c>
imap <Esc> <C-c>:file<CR>
nmap <C-l> : only<CR>
imap ` <C-c>

function! SwitchExt()
	let s:ext = expand('%:e')
	if s:ext == "h"
		let s:newname = expand('%<') . ".c"
	elseif s:ext == "c"
		let s:newname = expand('%<') . ".h"
	endif
	if exists(s:newname)
		execute "e! " . s:newname
	else
		if s:ext == "h"
			let s:newname = expand('%:t:r<') . ".c"
		elseif s:ext == "c"
			let s:newname = expand('%:t:r<') . ".h"
		endif
		execute "find " . s:newname
	endif
endfunction

aug QFClose
	au!
	au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
aug END

" CSCOPE
let g:cscope_silent = 1
let g:cscope_auto_update = 0
nnoremap fa :call CscopeFindInteractive(expand('<cword>'))<CR>
nnoremap <leader>f :call ToggleLocationList()<CR>

" taglist
execute "set <M-j>=\ej"
noremap <M-j> : Tlist<CR> : TlistUpdate<CR>
let g:Tlist_Show_One_File = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_Close_On_Select = 1
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Auto_Update = 0
let g:Tlist_Auto_Highlight_Tag = 1
set ut=500

" NERDTree
nmap <C-K> : NERDTreeFind<CR>

" syntastic
execute "set <M-i>=\ei"
noremap <M-i> : SyntasticCheck<CR>
execute "set <M-o>=\eo"
noremap <M-o> : Error<CR>
execute "set <M-p>=\ep"
noremap <M-p> : lclose<CR>
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_loc_list_height = 3

"BookmarkToggle
let g:bookmark_save_per_working_dir = 1
let g:bookmark_manage_per_buffer = 1
let g:bookmark_auto_save = 1
let g:bookmark_sign = '♥'
let g:bookmark_highlight_lines = 1
let g:bookmark_disable_ctrlp = 1
execute "set <M-b>=\eb"
noremap <M-b> : BookmarkShowAll<CR>
execute "set <M-m>=\em"
noremap <M-m> : BookmarkToggle<CR>
if filereadable('.vim-bookmarks')
	autocmd VimEnter * BookmarkLoad .vim-bookmarks
	if !filereadable('.vim-session') && argc()==0
		autocmd VimEnter * BookmarkShowAll
	endif
endif

" t9md/vim-quickhl
let g:quickhl_cword_enable_at_startup = 1
execute "set <M-v>=\ev"
nmap <M-v> <Plug>(quickhl-manual-this)
xmap <M-v> <Plug>(quickhl-manual-this)
execute "set <M-c>=\ec"
nmap <M-c> <Plug>(quickhl-manual-reset)

" ctrlp
let g:ctrlp_by_filename = 0
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_cache_dir = './.ctrlp_cache'
execute "set <M-k>=\ek"
let g:ctrlp_map = '<M-k>'

" ------------ Cscope -> QuickFix
" Close quickfix window after select an item
autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>:file<CR>
" This script adds keymap macro as follows:
" Find assignments to this symbol
nmap fa : cs f a  <cword><CR>
" Find this C symbol
nmap fs : cs f s  <cword><CR>
" Find this definition
nmap fg : cs f g  <cword><CR>
" Find functions called by this function
nmap fd : cs f d  <cword><CR>
" Find functions calling this function
nmap fc : cs f c  <cword><CR>
" Find this text string
nmap ft : cs f t  <cword><CR>
" Find this egrep pattern
nmap fe : cs f e<Space>
" Find this file
nmap ff : cs f f  <cfile><CR>
" Find files #including this file
nmap fi : cs f i  <cfile><CR>
" Cscope custom
nmap FF : cs f<Space>

execute "set <M-e>=\ee"
noremap <M-e> : cs f g <cword><CR>
execute "set <M-r>=\er"
noremap <M-r> : cs f s <cword><CR>
execute "set <M-t>=\et"
noremap <M-t> : cs f a <cword><CR>


function! GdbOutput()
	if filereadable("a.axf")
		! arm-none-eabi-gdb a.axf
	elseif filereadable("a.out")
		! arm-none-eabi-gdb a.out
	elseif filereadable("a.exe")
		! gdb a.exe
	endif
endfunction
let g:cscopeFileListName=".cscope.filelist"
function! CscopeDbUpdate()
	silent cscope reset
	if filereadable(g:cscopeFileListName)
		exec 'silent !cscope -bq -i '.g:cscopeFileListName
		redraw!
	else
		echo "Cscope: '" . g:cscopeFileListName . "' not found. Create cscope.out automatily. "
		exec 'silent !cscope -bqR'
		redraw!
	endif
	silent cscope add cscope.out
endfunction

if filereadable(g:cscopeFileListName)
	call CscopeDbUpdate()
endif
silent cscope add cscope.out

