set nu
set hlsearch
set cursorline
set ts=4
set shiftwidth=4
set autoindent
set incsearch
set ignorecase
set smartcase
set path+=$PWD/**

call plug#begin()
Plug 'JBakamovic/yaflandia'
Plug 'scrooloose/syntastic'
Plug 'ajh17/vimcompletesme'
Plug 'mattesgroeger/vim-bookmarks'
Plug 'scrooloose/nerdtree'
Plug 'brookhong/cscope.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 't9md/vim-quickhl'
call plug#end()

nmap > : vertical res +1<CR>
nmap < : vertical res -1<CR>
nmap Q <C-w>w :q<CR>
nmap <leader>s : %!astyle<CR>
nmap . <CR><C-w>wj<CR>
nmap , <CR><C-w>wk<CR>
let g:netrw_keepdir= 0

function! QuickFix_toggle()
	for i in range(1, winnr('$'))
		let bnum = winbufnr(i)
		if getbufvar(bnum, '&buftype') == 'quickfix'
			cclose
			return
		endif
	endfor
	execute "vert botright copen \| vert resize 200"
endfunction

execute "set <M-k>=\ek"
noremap <M-k> : find
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

aug QFClose
	au!
	au WinEnter * if winnr('$') == 1 && &buftype == "quickfix"|q|endif
aug END

" CSCOPE
let g:cscope_silent = 1
let g:cscope_auto_update = 1
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

" NERDTree
nmap <C-K> : NERDTreeToggleVCS<CR>

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

" ctags
" set tags+=.tags;/
" set tags+=tags;/
" set autochdir
" let g:autotagTagsFile=".tags"

"BookmarkToggle
let g:bookmark_auto_save = 1
let g:bookmark_sign = '♥'
let g:bookmark_highlight_lines = 1
execute "set <M-b>=\eb"
noremap <M-b> : BookmarkShowAll<CR>
execute "set <M-m>=\em"
noremap <M-m> : BookmarkToggle<CR>

" t9md/vim-quickhl
let g:quickhl_cword_enable_at_startup = 1
execute "set <M-v>=\ev"
nmap <M-v> <Plug>(quickhl-manual-this)
xmap <M-v> <Plug>(quickhl-manual-this)
execute "set <M-c>=\ec"
nmap <M-c> <Plug>(quickhl-manual-reset)


" ------------
" This script adds keymap macro as follows:
" <C-\> s: Find this C symbol
" <C-\> g: Find this definition
" <C-\> d: Find functions called by this function
" <C-\> c: Find functions calling this function
" <C-\> t: Find this text string
" <C-\> e: Find this egrep pattern
" <C-\> f: Find this file
" <C-\> i: Find files #including this file
" "this" means <cword> or <cfile> on the cursor.

if !exists("Cscope_OpenQuickfixWindow")
	let Cscope_OpenQuickfixWindow = 1
endif

if !exists("Cscope_JumpError")
	let Cscope_JumpError = 1
endif

" RunCscope()
" Run the cscope command using the supplied option and pattern
function! RunCscope(...)
	let usage = "Usage: Cscope {type} {pattern} [{file}]."
	let usage = usage . " {type} is [sgdctefi01234678]."
	if !exists("a:1") || !exists("a:2")
		echohl WarningMsg | echomsg usage | echohl None
		return
	endif
	let cscope_opt = a:1
	let pattern = a:2
	let openwin = g:Cscope_OpenQuickfixWindow
	let jumperr =  g:Cscope_JumpError
	if cscope_opt == '0' || cscope_opt == 's'
		let cmd = "cscope -L -0 " . pattern
	elseif cscope_opt == '1' || cscope_opt == 'g'
		let cmd = "cscope -L -1 " . pattern
	elseif cscope_opt == '2' || cscope_opt == 'd'
		let cmd = "cscope -L -2 " . pattern
	elseif cscope_opt == '3' || cscope_opt == 'c'
		let cmd = "cscope -L -3 " . pattern
	elseif cscope_opt == '4' || cscope_opt == 't'
		let cmd = "cscope -L -4 " . pattern
	elseif cscope_opt == '6' || cscope_opt == 'e'
		let cmd = "cscope -L -6 " . pattern
	elseif cscope_opt == '7' || cscope_opt == 'f'
		let cmd = "cscope -L -7 " . pattern
		let openwin = 0
		let jumperr = 1
	elseif cscope_opt == '8' || cscope_opt == 'i'
		let cmd = "cscope -L -8 " . pattern
	else
		echohl WarningMsg | echomsg usage | echohl None
		return
	endif
	if exists("a:3")
		let cmd = cmd . " " . a:3
	endif
	let cmd_output = system(cmd)

	if cmd_output == ""
		echohl WarningMsg |
		\ echomsg "Error: Pattern " . pattern . " not found" |
		\ echohl None
		return
	endif

	let tmpfile = tempname()
	let curfile = expand("%")

	if &modified && (!&autowrite || curfile == "")
		let jumperr = 0
	endif

	exe "redir! > " . tmpfile
	if curfile != ""
		silent echon curfile . " dummy " . line(".") . " " . getline(".") . "\n"
		silent let ccn = 2
	else
		silent let ccn = 1
	endif
	silent echon cmd_output
	redir END

	" If one item is matched, window will not be opened.
"	let cmd = "wc -l < " . tmpfile
"	let cmd_output = system(cmd)
"	exe "let lines =" . cmd_output
"	if lines == 2
"		let openwin = 0
"	endif

	let old_efm = &efm
	set efm=%f\ %*[^\ ]\ %l\ %m

	exe "silent! cfile " . tmpfile
	let &efm = old_efm

	" Open the cscope output window
	if openwin == 1
		vert botright copen
		vert resize 200
	endif

	" Jump to the first error
	if jumperr == 1
		exe "cc " . ccn
	endif

	call delete(tmpfile)
endfunction

" Define the set of Cscope commands
command! -nargs=* Cscope call RunCscope(<f-args>)

" nmap <C-@><C-@>s :Cscope s <C-R>=expand("<cword>")<CR><CR>
" nmap <C-@><C-@>g :Cscope g <C-R>=expand("<cword>")<CR><CR>
" nmap <C-@><C-@>d :Cscope d <C-R>=expand("<cword>")<CR> <C-R>=expand("%")<CR><CR>
" nmap <C-@><C-@>c :Cscope c <C-R>=expand("<cword>")<CR><CR>
" nmap <C-@><C-@>t :Cscope t <C-R>=expand("<cword>")<CR><CR>
" nmap <C-@><C-@>e :Cscope e <C-R>=expand("<cword>")<CR><CR>
" nmap <C-@><C-@>f :Cscope f <C-R>=expand("<cfile>")<CR><CR>
" nmap <C-@><C-@>i :Cscope i ^<C-R>=expand("<cfile>")<CR>$<CR>

execute "set <M-e>=\ee"
noremap <M-e> : Cscope g <C-R>=expand("<cword>")<CR><CR>
execute "set <M-r>=\er"
noremap <M-r> : Cscope c <C-R>=expand("<cword>")<CR><CR>


