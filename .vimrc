" Vim Settings
filetype off                            " required 
set nocompatible                        " be iMproved, required 
syntax on				" enable syntax highlighting
set t_Co=256				" enable 256 colors, true colors
set ruler               		" enable line and column number of the cursor on right side of statusline
set number relativenumber		" enable “Hybrid” line numbers
set path+=**                            " enable  searche current directory recursively.
set incsearch 				" enable incremental search 
set ignorecase                          " enable case-insensitive searching
set hidden                              " enable multiple buffers open
set showmatch           		" highlight matching parentheses / brackets [{()}]
set cursorline				" highlight the current line
set cursorcolumn			" highlight the current column
set wildmenu                            " Display all matches when tab complete.
set nobackup                            " No auto backups
set noswapfile                          " No swap


" Theme
" put colorscheme files in ~/.vim/colors/
colorscheme monochrome

" Load plugins 
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'ap/vim-css-color'
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
call plug#end()

" Set Leader Key
let mapleader=","

" Navigate around splits with a single key combo.
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" NerdTree
map <C-n> :NERDTreeToggle<CR>

" Recompile Suckless Programs Automatically
autocmd BufWritePost *config.h !doas make clean install %

" Location of viminfo
set viminfo+=n~/.vim/viminfo

