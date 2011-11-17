" Begin Vundle setup
syntax on
set nocompatible               " be iMproved
filetype off                   " required!
set nomodeline modelines=0

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle. Required!
Bundle 'git://github.com/gmarik/vundle'

Bundle 'git://github.com/leifwickland/vim-simple-sbt-integration'
Bundle 'git://github.com/leifwickland/vim-scala-ftplugin'

" You always forget that this plugin is broken because it has a .vim file in DOS format.
Bundle 'git://github.com/vim-scripts/cvsmenu.vim'
Bundle 'git://github.com/tpope/vim-fugitive'

Bundle 'git://github.com/rosstimson/scala-vim-support'

Bundle 'git@github.com:leifwickland/tagbar.git'

Bundle 'git://github.com/leifwickland/vim-php-support'
Bundle 'git://github.com/leifwickland/gitcommit-vim-support'

" I wish Ensime worked out of the box! _sigh_
" Bundle 'MarcWeber/vim-addon-async'
" Bundle 'MarcWeber/vim-addon-completion'
" Bundle 'MarcWeber/vim-addon-json-encoding'
" Bundle 'MarcWeber/ensime', {'rtp': 'vim/'}

filetype plugin indent on     " required! 
" End Vundle setup

" Brief Vundle help
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

set incsearch hlsearch

if has("gui_running")
  set guioptions+=a
  set guioptions-=T
  set guioptions-=r
  set guioptions-=l
  set guioptions-=R
  set guioptions-=L

  set title titlestring=VIM\ -\ %F\ %h "make sure that the window caption setting is turned on and set caption to vim 5.x style 

  au GUIEnter * simalt ~x " Maximize GVim on startup.
else 
  " I really like how this looks in Putty and really hate how it looks in gvim
  colorscheme desert
endif

" set the location swap files are written to
set directory=~/.vim/.swp
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

set grepprg+=\ -R

vmap * y/<c-r>"<cr>
set noequalalways
set eadirection="ver"
set diffopt+=iwhite,context:15
nnoremap ' `
nnoremap ` '

set textwidth=0 tabstop=2 shiftwidth=2 expandtab
set statusline=\[%02n\]%*%<\ %f\ %h%m%r%*%=%-14.(%l,%c%)%P
set laststatus=2 " Always show a status line.
set winminheight=0
set nobackup
set cmdheight=3
set showcmd "Dear self, please never remove this again. You'll miss the way it tells you the number of visually selected lines. Affectionately, self.

" Treat *.phph files as if they're *.php files.
au BufNewFile,BufRead *.phph            setf php

" Treat *.json files as javascript
au BufNewFile,BufRead *.json            setf javascript

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
