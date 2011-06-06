" Begin Vundle setup
syntax on
set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Bundle 'gmarik/vundle'

Bundle 'leifwickland/vim-simple-sbt-integration'
Bundle 'vim-scripts/cvsmenu.vim'
Bundle 'tpope/vim-fugitive'

filetype plugin indent on     " required! 
" End Vundle setup

" Misc Vundle help
" :BundleInstall  - install bundles (won't update installed)
" :BundleInstall! - update if installed
"
" :Bundles foo    - search for foo
"
" :BundleInstall  - install bundles (won't update installed)
" :BundleInstall! - update if installed
"
" :Bundles foo    - search for foo
" :Bundles! foo   - refresh cached list and search for foo
"
" :BundleClean    - confirm removal of unused bundles
" :BundleClean!   - remove without confirmation
"
" see :h vundle for more details

set incsearch
if has("gui_running")
    set guioptions+=a
    set guioptions-=T
    set guioptions-=r
    set guioptions-=l
    set guioptions-=R
    set guioptions-=L

    set title titlestring=VIM\ -\ %F\ %h "make sure that the window caption setting is turned on and set caption to vim 5.x style 
endif

colorscheme torte

" set the location swap files are written to
set directory=~/.vim/.swp
set tags=~/src/trunk/.tags,~/src/trunk/.tagsh
set cino+=(0,g0,:0
nmap <m-]>  :let tagword=expand("<cword>")<CR>:exe "tj ".tagword<CR>
nnoremap <m-}>  :let tagword=expand("<cword>")<CR>:exe "stj ".tagword<CR>
vnoremap <m-]> y:tj <c-r>"<cr>
vnoremap <m-}> y:stj <c-r>"<cr>
nnoremap <m-*> yiw:grep "<c-r>"" *.c<cr>:copen 7<cr>
nnoremap <F8> :let @/=''<cr>
inoremap <F8> <c-o>:let @/=''<cr>
nmap K k
nmap <c-k> k

vmap * y/<c-r>"<cr>
set noequalalways
set eadirection="ver"
set diffopt+=iwhite,context:15
nnoremap ' `
nnoremap ` '

"set ts=4 sw=4 expandtab
set laststatus=2
set winminheight=0
set nobackup
set cmdheight=3

" Treat *.phph files as if they're *.php files.
au BufNewFile,BufRead *.phph            setf php

" In order to show matches and to format (), [], and {} nicely when they
" appear on multiple lines.
set showmatch matchtime=15
inoremap } }<bs>}
inoremap ) )<bs>)
inoremap ] ]<bs>]

" Correct common misspellings of common commands
command! -nargs=? Res :res <args>
command! -nargs=? Re :res <args>
command! -nargs=? R :res <args>
cabbr mka mak
cab re res
command! -nargs=? E :Explore <args>
