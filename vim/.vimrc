python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256
"set number
"autocmd FileType yaml setlocal autoindent tabstop=2 shiftwidth=2 expandtab

" CTRL P will open fzf
nnoremap <C-p> :Files<Cr>

" Install vim-plug if not found

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" NERDtree
  Plug 'preservim/nerdtree'

" fuzzyfinder
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

" vim-ansible
  Plug 'pearofducks/ansible-vim' 

" dracula colorscheme
  Plug 'dracula/vim', { 'as': 'dracula' }

" everforest colorscheme  
  Plug 'sainnhe/everforest'

" gruvbox colorscheme  
  Plug 'sainnhe/gruvbox-material'

" nord colorscheme
  Plug 'arcticicestudio/nord-vim'

" Initialize plugin system
call plug#end()
