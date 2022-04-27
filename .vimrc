set encoding=utf8

" Enable folding
set foldmethod=indent
set foldlevel=99

"""""""""""""""""""""""""""""""""""""
" Configuration Section
"""""""""""""""""""""""""""""""""""""
" OSX stupid backspace fix
set backspace=indent,eol,start

" Show linenumbers
set number

" Set Proper Tabs
set tabstop=2
set shiftwidth=2
set smarttab
set expandtab

" Always display the status line
set laststatus=2

" system clipboard
set clipboard=unnamed

" Enable highlighting of the current line
set cursorline

" Theme and Styling
syntax on
set t_Co=256

" Set file ignore QOL
set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set wildignore+=*/node_modules/*

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Set auto and smart indents
set ai
set si


