set nu
set hlsearch
set cursorline
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set autoindent
set incsearch
set ignorecase
set smartcase
set linebreak
set nowrap
set tags=.tags
set complete-=i
set shortmess+=c
set completeopt+=menuone,noselect,menu
set completeopt-=preview
set scrolloff=3
set path+=$PWD/**
set encoding=utf-8
set dir=/tmp/
set backspace=2
set tm=10
set t_Co=256
set pastetoggle=<F12>
exec "silent !stty -ixon"
exec "try\n let &t_TI = '' \ncatch\nendtry"
exec "try\n let &t_TE = '' \ncatch\nendtry"
let g:temp_dir = $HOME

call plug#begin()
Plug 'JBakamovic/yaflandia'
Plug 'scrooloose/nerdtree'
Plug 'brookhong/cscope.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'MattesGroeger/vim-bookmarks'
Plug 't9md/vim-quickhl'
Plug 'kien/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
"Plug 'ajh17/vimcompletesme'
call plug#end()

nmap + : vertical res +1<CR>
nmap _ : vertical res -1<CR>
nmap <leader>s : %!astyle<CR>
nmap , <C-w>W
nmap . <C-w>w
nmap < : call GoPrevPage()<CR><C-g>
nmap > : call GoNextPage()<CR><C-g>
nmap ? : call ClosePage()<CR>
nmap C : only<CR><C-g>
nmap ; %
vmap ; %
nmap ' zz
nmap W <C-b>
nmap S <C-f>
nmap <C-c> :w !xclip<CR><C-g>
vmap <C-c> :'<,'>w !xclip<CR><C-g>
nmap <F5> :redraw!<CR>
let g:netrw_keepdir= 0

" Session config for workspace
exec "silent !mkdir -p " . g:temp_dir . "/.vim-session/"
let g:session_path = getcwd() . '/.session'
let g:session_path = g:temp_dir . '/.vim-session/' . substitute(g:session_path, "/", "_", "g")
let g:save_session = 1
nmap Q : exec 'silent !rm -f '.g:session_path <CR>:let g:save_session=0<CR>:qa!<CR>
function! MakeSession()
    if g:save_session == 1
        exec "mksession! " . g:session_path
    endif
endfunction
if filereadable(g:session_path)
    exec 'if argc()==0|silent source '. g:session_path .'|endif'
endif
autocmd VimLeave * :call MakeSession()

function! QuickFix_toggle()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            cclose
            file
            return
        endif
    endfor
"    execute 'vert botright copen \| vert resize 200'
    execute "copen \| res ".winheight(0)/2
endfunction

function! GoPrevPage()
    if tabpagenr('$') == 1
        exec 'bp'
    else
        exec 'normal gT'
    endif
endfunction

function! GoNextPage()
    if tabpagenr('$') == 1
        exec 'bn'
    else
        exec 'normal gt'
    endif
endfunction

function! ClosePage()
    if tabpagenr('$') == 1
        exec 'bd'
    else
        exec 'q'
    endif
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
execute "set <M-Q>=\eQ"
noremap <M-Q> : !make clean<CR>
execute "set <M-A>=\eA"
noremap <M-A> : call CscopeDbUpdate()<CR>
execute "set <M-S>=\eS"
noremap <M-S> : %!astyle<CR>
noremap <C-S> : exec 'silent! %s/\t/    /g'<CR> : exec 'silent! %s/\s\+$//g'<CR> : w <CR>
execute "set <M-D>=\eD"
noremap <M-D> : !make menuconfig<CR>
execute "set <M-F>=\eF"
noremap <M-F> : call GdbOutput()<CR>
execute "set <M-C>=\eC"
noremap <M-C> : silent make -j16<CR>:redraw!<CR>: call QuickFix_toggle()<CR>
execute "set <M-Z>=\eZ"
noremap <M-Z> : tabe ~/.gdbinit<CR>
execute "set <M-X>=\eX"
noremap <M-X> : tabe ./.gdbinit.local<CR>
execute "set <M-t>=\et"
noremap <M-t> : exec 'silent !mkdir -p ' . g:temp_dir . '/.note' . getcwd()<CR> :exec ' tabe ' . g:temp_dir . '/.note' . getcwd() . '/note.txt'<CR>:redraw!<CR>
execute "set <M-T>=\eT"
noremap <M-T> : exec 'silent !mkdir -p ' . g:temp_dir . '/.note' <CR> :exec ' tabe ' . g:temp_dir . '/.note' . '/note.txt'<CR>:redraw!<CR>
execute "set <M-1>=\e1"
noremap <M-1> [[
execute "set <M-2>=\e2"
noremap <M-2> ]]
execute "set <M-h>=\eh"
noremap <M-h> : call SwitchExt()<CR>
execute "set <M-l>=\el"
imap <M-l> <C-c>
execute "set <M-o>=\eo"
noremap <M-o> yiw
execute "set <M-p>=\ep"
noremap <M-p> viwpyiw
nmap <C-l> : only<CR>

" .c/.h quich switch
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

" taglist
execute "set <M-j>=\ej"
noremap <M-j> : Tlist<CR> : TlistUpdate<CR>
let g:Tlist_Show_One_File = 1
let g:Tlist_GainFocus_On_ToggleOpen = 1
let g:Tlist_Close_On_Select = 1
let g:Tlist_Exit_OnlyWindow = 1
let g:Tlist_Auto_Update = 0
let g:Tlist_Auto_Highlight_Tag = 1
let g:Tlist_WinWidth = winwidth(0)/4
set ut=500

" NERDTree
nmap <C-K> : NERDTreeFind<CR>


"BookmarkToggle
let g:bookmark_sign = '♥'
let g:bookmark_disable_ctrlp = 1
let g:bookmark_auto_save = 0
let g:bookmark_save_per_working_dir = 1
let g:bookmark_manage_per_buffer = 0
execute "set <M-m>=\em"
noremap <M-m> : BookmarkToggle<CR>
execute "set <M-M>=\eM"
noremap <M-M> : BookmarkAnnotate<CR>
nmap m : BookmarkShowAll<CR>
let g:bookmark_path = getcwd() . '/.bookmark'
let g:bookmark_path = g:temp_dir . '/.vim-bookmarks/' . substitute(g:bookmark_path, "/", "_", "g")
if argc()==0
    exec "silent !mkdir -p " . g:temp_dir . "/.vim-bookmarks/"
    exec 'autocmd VimLeave * BookmarkSave ' . g:bookmark_path
    if filereadable(g:bookmark_path)
        exec 'autocmd VimEnter * BookmarkLoad ' . g:bookmark_path
        if !filereadable(g:session_path)
            autocmd VimEnter * BookmarkShowAll
        endif
    endif
else
    let g:save_session = 0
endif

" t9md/vim-quickhl
execute "set <M-v>=\ev"
nmap <M-v> <Plug>(quickhl-manual-this-whole-word)
execute "set <M-c>=\ec"
nmap <M-c> :noh<CR><Plug>(quickhl-manual-reset)<C-g>
nmap ` : QuickhlCwordToggle<CR>
" ctrlp
let g:ctrlp_by_filename = 0
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_cache_dir = g:temp_dir.'/.ctrlp_cache'.getcwd()
execute "set <M-k>=\ek"
let g:ctrlp_map = '<M-k>'

" CSCOPE
let g:cscope_silent = 1
let g:cscope_auto_update = 0
" ------------ Cscope -> QuickFix
" Close quickfix window after select an item
autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR><C-g>
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

execute "set <M-E>=\eE"
noremap <M-E> : call FindDefine()<CR>
execute "set <M-r>=\er"
noremap <M-r> : cs f s <cword><CR>
execute "set <M-R>=\eR"
noremap <M-R> : cs f c <cword><CR>
execute "set <M-f>=\ef"
noremap <M-f> : cs f e<Space>
execute "set <M-e>=\ee"
noremap <M-e> : cs f g <cword><CR><C-g>

function! FindDefine()
    exec "silent only"
    exec ":vs"
    exec "normal \<C-w>\<C-w>"
    exec "silent! cs f g \<cword>"
    exec "normal lw"
    exec "silent! cs f g \<cword>"
    exec "normal zz"
    exec "vertical resize ".(winwidth(0)*2/3)
    exec "normal \<C-w>\<C-p>\<C-g>"
endfunction

function! GdbOutput()
    if filereadable("a.axf")
        ! arm-none-eabi-gdb -x .gdbinit.local a.axf
    elseif filereadable("a.out")
        ! arm-none-eabi-gdb -x .gdbinit.local a.out
    elseif filereadable("a.exe")
        ! gdb -x .gdbinit.local a.exe
    endif
endfunction
let g:cscopeFileListName=".cscope.filelist"
let g:cscope_path = getcwd()
let g:cscope_path = g:temp_dir . '/.cscope_cache/' . substitute(g:cscope_path, "/", "_", "g") . '/'
exec "silent !mkdir -p " . g:cscope_path
function! CscopeDbUpdate()
    silent cscope reset
    if filereadable(g:cscopeFileListName)
        exec 'silent !cscope -bq -f '.g:cscope_path.'cscope.out -i '.g:cscopeFileListName
        redraw!
    else
        echo "Cscope: '" . g:cscopeFileListName . "' not found. Create cscope.out automatily. "
        exec 'silent !cscope -bqR -f'.g:cscope_path.'cscope.out'
        redraw!
    endif
    exec 'silent cscope add '.g:cscope_path.'cscope.out'
endfunction

if filereadable(g:cscopeFileListName)
    call CscopeDbUpdate()
endif
if filereadable(g:cscope_path.'cscope.out')
    exec 'silent cscope add '.g:cscope_path.'cscope.out'
endif

" vim airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
"let g:airline_section_a = ''
let g:airs_b = ''
let g:airs_c = ''
let g:airs_x = ''
let g:airline_section_b = '%{g:airs_b}'
let g:airline_section_c = '%{g:airs_c}'
let g:airline_section_x = '%{g:airs_x}'
"let g:airline_section_y = ''
"let g:airline_section_warning = ''
let timer = timer_start(10000, 'UpdateTime',{'repeat':-1})
function! UpdateTime(timer)
    let g:airs_b = system('if command -v airs_b > /dev/null 2>&1; then airs_b | tr -d "\n"; fi')
    let g:airs_c = system('if command -v airs_c > /dev/null 2>&1; then airs_c | tr -d "\n"; fi')
    let g:airs_x = system('if command -v airs_x > /dev/null 2>&1; then airs_x | tr -d "\n"; fi')
    let &ro = &ro
endfunction

" gitgutter
nmap ) : GitGutterNextHunk<CR>
nmap ( : GitGutterPrevHunk<CR>

