set encoding=utf8

" Enable folding
set foldmethod=indent
set foldlevel=99

"""" START Vundle Configuration

" Disable file type for vundle
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Utility
Plugin 'scrooloose/nerdtree'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'majutsushi/tagbar'
Plugin 'wesQ3/vim-windowswap'

" Generic Programming Support
Plugin 'honza/vim-snippets'
Plugin 'Townk/vim-autoclose'
Plugin 'vim-syntastic/syntastic'
Plugin 'Chiel92/vim-autoformat'
Plugin 'prettier/vim-prettier'

" Javascript
Plugin 'pangloss/vim-javascript'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'maksimr/vim-jsbeautify'
Plugin 'othree/javascript-libraries-syntax.vim'

" Python
Plugin 'vim-scripts/indentpython.vim'

" Git Support
Plugin 'kablamo/vim-git-log'
Plugin 'gregsexton/gitv'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

" PHP Support
"Plugin 'phpvim/phpcd.vim'
Plugin 'tobyS/pdv'


" Themes & Interface
Plugin 'ryanoasis/vim-devicons'
Plugin 'junegunn/limelight.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'joshdick/onedark.vim'

" Docker, etc...
Plugin 'skanehira/docker-compose.vim'
Plugin 'ekalinin/Dockerfile.vim'


call vundle#end()            " required
filetype plugin indent on    " required
"""" END Vundle Configuration

"""""""""""""""""""""""""""""""""""""
" Configuration Section
"""""""""""""""""""""""""""""""""""""
set nowrap


" Show linenumbers
set number

" Set Proper Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

" Always display the status line
set laststatus=2

" system clipboard
set clipboard=unnamed


" Devicons configuration
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = ''

" Enable highlighting of the current line
set cursorline

" Theme and Styling
syntax on
set t_Co=256
colorscheme onedark

" Javascript Config
let g:vim_jsx_pretty_colorful_config = 1
let g:used_javascript_libs = 'react'

" Vim-Airline Configuration
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme ='onedark'
let g:hybrid_custom_term_colors = 1
let g:hybrid_reduced_contrast = 1

" Syntastic Configuration
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1



"""""""""""""""""""""""""""""""""""""
" Mappings configurationn
"""""""""""""""""""""""""""""""""""""
map <C-n> :NERDTreeToggle<CR>
map <C-m> :TagbarToggle<CR>

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"

" Mapping selecting Mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Shortcuts
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>O :CtrlP<CR>
nnoremap <Leader>w :w<CR>

map <silent> <LocalLeader>ws :highlight clear ExtraWhitespace<CR>

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding with the spacebar
noremap <space> za
