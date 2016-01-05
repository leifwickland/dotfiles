" Begin NeoBundle setup
"
"

if has('vim_starting')
  if &compatible
    set nocompatible
  endif

  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))


" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" After install, cd ~/.vim/bundle/vimproc.vim; make -f your_machines_makefile
" Allows Neobundle to update itself in parallel.
NeoBundle 'https://github.com/Shougo/vimproc.vim'

" Highlights syntax errors on file save.
NeoBundle 'https://github.com/scrooloose/syntastic'
let g:syntastic_loc_list_height=3
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_jump = 1
let g:syntastic_scala_checkers = ['fsc'] " Only use `fsc` and not `scalac`
let g:syntastic_php_checkers = ['php'] " Only use `php` and not `phpcs`.
let g:syntastic_java_checkers = [''] " Disable java because making dependencies work sucks.
if has("gui_running")
  let g:syntastic_error_symbol = '✗'
  let g:syntastic_warning_symbol = '⚠'
endif

" Scala support
NeoBundle 'https://github.com/derekwyatt/vim-scala/'
NeoBundle 'ssh://github.com/leifwickland/vim-scala-ftplugin'
NeoBundle 'ssh://github.com/leifwickland/scala-vim-support'

" Dear self, you always forget that this plugin is broken because it has a .vim file in DOS format.
" I ended up making my own repo so I could fix that irritation.
NeoBundle 'ssh://github.com/leifwickland/cvsmenu.vim'

" Git support
NeoBundle 'https://github.com/tpope/vim-fugitive'

" PHP support
NeoBundle 'ssh://github.com/leifwickland/vim-php-support'

" Markdown support
NeoBundle 'https://github.com/tpope/vim-markdown'

" Full path fuzzy file, buffer, mru, tag, ... finder for Vim.
NeoBundle 'https://github.com/kien/ctrlp.vim'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
let g:ctrlp_extensions = ['tag']
let g:ctrlp_working_path_mode = 'w' " Search from the working directory instead of relative to the file.
nnoremap <C-u> :CtrlPTag<cr>
if has('gui_running')
  nnoremap <A-p> :CtrlPBuffer<cr>
else
  nnoremap p :CtrlPBuffer<cr>
endif

" Beautify Javascript. Clone of jsbeautify.org.
NeoBundle 'https://github.com/vim-scripts/jsbeautify'

"Compiler support for Mono's C# compiler, gmcs
NeoBundle 'https://github.com/vim-scripts/gmcs.vim'

" Fancy status line
if has("gui_running")
  NeoBundle 'https://github.com/bling/vim-airline'
endif

" Solarized color schemes
NeoBundle 'https://github.com/altercation/vim-colors-solarized'
let g:solarized_contrast="high"

" Improves the directory listing shown by :Explore
NeoBundle 'https://github.com/tpope/vim-vinegar'

" Table alignment
NeoBundle 'https://github.com/vim-scripts/vim-easy-align.git'

" End NeoBundle setup
call neobundle#end()
filetype plugin indent on
NeoBundleCheck

" I typically like my terminals to have light backgrounds
set background=light

syntax enable
syntax on

set wildignore+=*.class
set wildignore+=*/target/*
set wildignore+=*/.git/*
set wildignore+=*/.svn/*
set wildignore+=*/.hg/*
set wildignore+=*/cvs/*

" Highlight search results. Search incrementally as I type.
set hlsearch incsearch

if has("gui_running")
  set guioptions-=m " Don't display menu
  set guioptions+=a " Allow vim to magically put things on the clipboard
  set guioptions-=T " No toolbar
  set guioptions-=r " Hide scrollbar on right
  set guioptions-=R " Hide scrollbar on right
  set guioptions-=l " Hide scrollbar on left
  set guioptions-=L " Hide scrollbar on left

  set title titlestring=VIM\ -\ %F\ %h "make sure that the window caption setting is turned on and set caption to vim 5.x style

  if has('win32')
    au GUIEnter * simalt ~x " Maximize GVim on startup in Windows
  endif
  set background=light
  colorscheme solarized
  if has('mac')
    set guifont=Menlo\ Regular:h14
  else 
    set guifont=Source\ Code\ Pro\ Medium\ 10
  endif 
else
  " I'm leaving this here in case I use airline again.
  let g:airline_theme='kolor'
  " I really like how this scheme looks in Putty and really hate how it looks in gvim
  colorscheme desert
endif

" set the location swap files are written to
set directory=~/.vim/.swp

if version >= 703
  " Let vim create undo files so changes can be undone across file reloads
  " Came into existence in vim 7.3.
  set undofile
  set undodir=~/.vim/.undo
else
endif

" Fiddle with indentation options.
set cino+=(0,g0,:0

" Use F8 to clear search highlighting
nnoremap <F8> :noh<cr>
inoremap <F8> <c-o>:noh<cr>

" The odds that I meant 'look up a man page for the word under the cursor'
" rather than go up are infinitesimally small.
nmap K k

" Idem. above except digram characters.
nmap <c-k> k

" Yes, please, grep recursively.
set grepprg+=\ -R

" Scala specific grep
command! -nargs=+ GS :grep --include='*.scala' <args> */
command! -nargs=+ GSS :grep --include='*.scala' <args>

vmap * y/<c-r>"<cr>

" No, I don't want you to keep all the windows the same height.
set noequalalways

" But I do want to keep all windows the same width by default.
set eadirection="ver"

set diffopt+=iwhite,context:15,vertical

" Swap around ' and ` because the ` version jumps to a particular line and column, not just a particular line.
nnoremap ' `
nnoremap ` '

" Don't wrap. Indent 2 spaces. Use spaces, not tabs.
set textwidth=0 tabstop=2 shiftwidth=2 expandtab

" Include useful stuff in the status line: buffer number, file name, current line & column, percentage through file.
set statusline=\[%02n\]%*%<\ %f\ %h%m%r%*%=%-14.(%l,%c%)%P

" Always show a status line.
set laststatus=2

"Allow my windows to be smushed to zero height.
set winminheight=0

" How about I use version control instead of having every file write result in a .bak file?
set nobackup

" Dear self, please never remove this again. You'll miss the way it tells you the number of visually selected lines. Affectionately, self.
set showcmd

"Remember more lines of command line history, please.
set history=9999

" Make ctrl-\ like ctrl-], but split the window
nnoremap <c-\> :stag <c-r><c-w><cr>

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
command! -nargs=? E :Explore <args>
cabbr mka mak
cab re res
cab SEx Sex

" Some Scala syntax seems to confuse vim into thinking it's found a mode line,
" which breaks fugitive's ability to diff those files.
" I really don't understand why modelines are being detected outside of the
" default 5 line window at the beginning and end of the files, but they seem
" to be. Shrug. Moving on.
set nomodeline
