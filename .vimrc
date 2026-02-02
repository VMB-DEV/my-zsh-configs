" Show line number absolute and relatives
set rnu
set nu
set nowrap
" Show syntax
syntax on
" Show file stats
set ruler

" Blink cursor on error instead of beeping (grr)
" set visualbell
" Disable the bell
"set belloff

set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround
set showmode
set history=1000

set mouse=a

" color desert
" color lunaperche
" color wildcharm
" color slate
color habamax

" Make counted j/k motions add to jump list
nnoremap <expr> j (v:count > 1 ? "m'" . v:count : "") . 'j'
nnoremap <expr> k (v:count > 1 ? "m'" . v:count : "") . 'k'
