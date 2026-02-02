" for vim -u ~/.vimrc_r
set nocompatible
source $VIMRUNTIME/defaults.vim

" reset all settings
" set all&

" search uncommented print
" \(#.*\)\@<!print

syntax on
" syntax enable
filetype plugin indent on

" to display Chinese properly
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
set enc=utf8
set fencs=utf8,gbk,gb2312,gb18030

set noswapfile

" set sessionoptions+=globals
" set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize,terminal

set viminfo='5000,<50,s10,h

set nofixeol

set shortmess-=S

set conceallevel=0

" auto fold comments in python
" autocmd FileType python setlocal foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*#'

"make Rg also search symbolic link
command! -bang -nargs=* Rg call fzf#vim#grep("rg --follow --column --line-number --no-heading --color=always --smart-case -- ".fzf#shellescape(<q-args>), 1, fzf#vim#with_preview(), <bang>0)

" Session management
function! s:InitSessionName()
  " Prioritize session name from environment variable, then existing global var,
  " and fall back to directory name.
  if exists('$VIM_SESSION_NAME') && !empty($VIM_SESSION_NAME)
    let g:SessionName = $VIM_SESSION_NAME
  elseif !exists('g:SessionName')
    " Use a sanitized version of the current directory name as the session name
    let g:SessionName = substitute(fnamemodify(getcwd(), ':t'), '[^a-zA-Z0-9_.-]', '_', 'g')
    " If the name is empty (e.g. we are in '/'), use a default
    if empty(g:SessionName)
      let g:SessionName = 'root'
    endif
  endif
endfunction

function! LoadSession()
  call s:InitSessionName()
  let session_file = expand('~/.auto_session_' . g:SessionName . '.vim')
  if filereadable(session_file)
    execute 'source' session_file
    call Sb() " Also restore fzf buffers
  endif
endfunction

" autocmd VimEnter * call LoadSession()

" save and recover fzf sorted buffers
" convert the number in g:fzf#vim#buffers from exponentional expression to float
function! Pd()
    let g:fzf#vim#buffers#full = {}
    for [key, value] in items(g:fzf#vim#buffers)
        let g:fzf#vim#buffers#full[bufname(eval(key))] = printf('%.6f', (value))
    endfor
    " echo g:fzf#vim#buffers#full
endfunction
" save fzf sorted buffer order, 'make buffer'.
function! Mb()
    call Pd()
    if exists('g:SessionName')
        call writefile([string(g:fzf#vim#buffers#full)], expand('~/.fzf_buffers_' . g:SessionName . '.txt'))
    endif
endfunction
" recover fzf sorted buffer order, 'source buffer'.
function! Sb()
    if exists('g:SessionName')
        let buffer_file = expand('~/.fzf_buffers_' . g:SessionName . '.txt')
        if filereadable(buffer_file)
            let g:fzf#vim#buffers#read = eval(readfile(buffer_file)[0])
            for [key, value] in items(g:fzf#vim#buffers#read)
                let g:fzf#vim#buffers[bufnr(key)] = eval(value)
            endfor
        endif
    endif
endfunction

" keep n lines visible above and below cursor at all times
set scrolloff=0
" set scrolloff=10
" keep n columns visible left and right of the cursor at all times
" set sidescrolloff=0
set sidescrolloff=30

" turn page
noremap <C-u> <C-b>

" clear all key mappings
" mapclear | mapclear <buffer> | mapclear! | mapclear! <buffer>

" try to fix u undo, ctrl+r redo, caused by vim-repeat, verbose map <Plug>(RepeatUndo)
nnoremap u u
nnoremap <C-R> <C-R>

" set autoindent
" " On pressing tab, insert 2 spaces
" set expandtab
" " show existing tab with 2 spaces width
" set tabstop=2
" " press tab = 2 spaces
" set softtabstop=2
" " when indenting with '>', use 2 spaces width
" set shiftwidth=2

" set autoindent with 2 or 4 spaces
" set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
set autoindent expandtab tabstop=4 softtabstop=4 shiftwidth=4
" set noautoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2

" to solve 'Last set from /usr/local/Cellar/vim@8.2.4700/8.2.4700/share/vim/vim82/ftplugin/python.vim line 119'
let g:python_recommended_style=0
augroup my_python_settings
    autocmd!
    " autocmd FileType python set noautoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
    " autocmd FileType python set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile */TLeague/**.py set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile */TPolicies/**.py set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2
    autocmd BufRead,BufNewFile */**.jinja2 set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2 filetype=python
    autocmd BufRead,BufNewFile */TairLearning/**.py set autoindent expandtab tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile */MeGraph/**.py set autoindent expandtab tabstop=4 softtabstop=4 shiftwidth=4
    autocmd BufRead,BufNewFile */**.launch set autoindent expandtab tabstop=2 softtabstop=2 shiftwidth=2 filetype=xml
    autocmd BufRead,BufNewFile */**.kbd set autoindent expandtab tabstop=4 softtabstop=4 shiftwidth=4 filetype=lisp
augroup END

augroup my_tex_settings
    autocmd!
    autocmd BufRead,BufNewFile *.tex inoremap <C-s> <Esc>`^:w<CR>
augroup END

" set signcolumn=no


let g:NERDTreeHijackNetrw=0
let g:NERDTreeNodeDelimiter = "\u00a0"
" set autochdir
set noautochdir
set display=lastline
" set ts=4
" hilight search
set hlsearch

" configure '_' as a word separator
" set iskeyword-=_

" clear the search register
noremap <silent> <space> :let @/=""<CR>
" set cmdheight=1

" set complete=.,w,b,u,t,i
" set complete-=t
set complete=.
" verbose set complete ? (for verify)
"
" source ~/.tair.vim
" source ~/cscope_maps.vim
" compile .tex latex file when :w
" autocmd BufWritePost *.tex silent! execute "!pdflatex % >/dev/null 2>&1" | redraw!
" autocmd BufWritePost *.py silent! !cd ~/workspace/TAIRCraft-autobuild/ && ctags -R &
set tags=
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/zmq/tags
" set tags+=~/workspace/human_aware_rl_neurips2019/tags
set tags+=~/workspace/music/tags
set tags+=~/anaconda3/lib/python3.6/site-packages/numpy/tags
set tags+=~/workspace/TAIRCraft-autobuild/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/tensorflow_core/python/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/tensorflow_core/contrib/tags
set tags+=~/workspace/snake_coma_v_01/tags
set tags+=~/workspace/Arena/tags
set tags+=~/workspace/TImitate/tags
set tags+=~/workspace/PySC2TencentExtension/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/gym/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/pommerman/tags
set tags+=~/anaconda3/envs/futu/lib/python3.6/site-packages/futu/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/pybullet_envs/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/pybullet_examples/tags
set tags+=~/anaconda3/envs/tair/lib/python3.6/site-packages/pybullet_utils/tags
set tags+=~/workspace/bullet3/tags
set tags+=~/anaconda3/envs/pytorch/lib/python3.7/site-packages/torch/tags
set tags+=~/workspace/TAIRCraft-autobuild/taircraft-gazebo/tags
set tags+=~/workspace/TAIRCraft-autobuild-humanoid/tags
" set tags+=~/workspace/TLeague/tags
" cscope
" set cscopetag
" csto=1 use ctags for definition; csto=0 use cscope for definition.
" set csto=1
" nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
" nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
" nmap <C-\>s <C-\>s
" nmap <C-]> g<C-]>
" nmap <C-]> <C-]>
" nmap <C-]> :cs find s <C-R>=expand("<cword>")<CR><CR>	
" cs add ~/workspace/TAIRCraft-autobuild/cscope.out
" cs add ~/anaconda3/envs/tair/lib/python3.6/site-packages/tensorflow_core/python/cscope.out
" cs add ~/anaconda3/envs/tair/lib/python3.6/site-packages/tensorflow_core/contrib/cscope.out
" cs add ~/workspace/snake_coma_v_01/cscope.out
" cs add ~/workspace/Arena/cscope.out
" cs add ~/workspace/TImitate/cscope.out
" cs add ~/workspace/PySC2TencentExtension/cscope.out
" cs add ~/anaconda3/envs/tair/lib/python3.6/site-packages/gym/cscope.out

" netrw config for file browsing
" let g:netrw_banner=1	" enable/disable banner
" let g:netrw_browse_split=0	" open in prior window
" let g:netrw_altv=1 	" open splits to the right
" let g:netrw_liststyle=0

"Pylint
" :compiler! pylint
set makeprg=pylint\ --rcfile=~/.pylintrc\ --reports=n\ --output-format=parseable\ %:p
" set makeprg=pylint\ --reports=n\ --msg-template=\"{path}:{line}:\ {msg_id}\ {symbol},\ {obj}\ {msg}\"\ %:p
set errorformat=%f:%l:\ %m

set wildignore+=*tags
set wildignore+=*cscope.out
" set tags=./tags,tags;
" auto save session (open files in the buffer) on quite
" autocmd VimLeave * execute 'mksession! ' . getcwd() . '~/.session.vim'
" autocmd VimLeave * execute 'mks! ~/.auto_session.vim' | call Mb()
" autocmd BufWritePost,VimLeave * execute 'mks! ~/.auto_session.vim' | call Mb()
autocmd BufWritePost,VimLeave * if exists('g:SessionName') | execute 'mks! ~/.auto_session_' . g:SessionName . '.vim' | call Mb() | endif

" nnoremap <C-p> :find ./**/*
" search down in subfolders
set path+=**
" display all matching files while tab complete; ctrl+e to stop complete;
" ctrl+d to list all options
set wildmenu
" noremap <C-p> :find ~/workspace/TAIRCraft-autobuild/**/*

" fzf MRU search
command! FZFMru call fzf#run({
\  'source':  v:oldfiles,
\  'sink':    'e',
\  'options': '-m -x +s',
\  'window': {'width': '110%', 'height': '25%'}})

" fzf Jumps
function! GetJumps()
  redir => cout
  silent jumps
  redir END
  " return reverse(split(cout, "\n")[1:])
  return reverse(split(cout, "\n")[0:])
endfunction
function! GoToJump(jump)
    let jumpnumber = split(a:jump, '\s\+')[0]
    execute "normal " . jumpnumber . "\<c-o>"
endfunction
command! Jumps call fzf#run(fzf#wrap({
        \ 'source': GetJumps(),
        \ 'sink': function('GoToJump')}))

" fzf key binds
noremap <C-p> :Buffers<CR>
noremap <NUL> :Buffers<CR>
" noremap <C-p> :FZFMru<CR>
noremap <silent><space>lb :Buffers<CR>
noremap <leader>d :Tags<CR>
noremap <silent><space>ld :Tags <C-R><C-W><CR>
noremap <leader>s :BTags<CR>
noremap <silent><space>ls :BTags<CR>
noremap <leader>r :Rg<CR>
noremap <silent><space>lr :Rg <C-R><C-W><CR>
noremap <leader>f :Files<CR>
noremap <silent><space>lf :Files<CR>
noremap <leader>h :History<CR>
noremap <silent><space>lh :History<CR>
" noremap <leader>o :FZFMru<CR>
" noremap <silent><space>lo :FZFMru<CR>
noremap <silent><space>lj :Jumps<CR>
" nnoremap <silent><space>lw :Tags <C-R><C-W><cr>
noremap <silent><space>lg :GF?<CR>

" search for uncommented print
noremap <silent><space>l/ /\(#.*\)\@<!print<CR>

" context key binds
" let g:context_enabled = 0 " did not work
nnoremap <silent><nowait> <space>lc  :<C-u>ContextToggle<cr>

" undotree
nnoremap <silent><space>lu :UndotreeToggle<CR>
set undofile
let target_path = expand('~/.undodir')
if !isdirectory(target_path)
    call mkdir(target_path, "p", 0700)
endif
set undodir=~/.undodir


"Allow switch buffer without saving the file
" set hidden

"Always show the status bar
set laststatus=2
" Add full file path to your existing statusline
set statusline=""
set statusline+=%F

" setlocal keywordprg=git\ show
set keywordprg=git\ show

"snippets
" nnoremap ,f :-1read ~/.vim/.print_skeleton.py<CR>

set clipboard=
" set clipboard=unnamed
" for xclip on server
" vmap <silent>"+y :silent w !xclip -sel clip<CR>
" nmap <C-t> :NERDTreeToggle<CR>
nmap <C-n> :NERDTreeToggle<CR>
" reveal the file in nerdtree
nmap <leader><C-r> :NERDTreeFind<CR>
" auto close nerdtree when open file
let g:NERDTreeQuitOnOpen = 1
" default window size
let g:NERDTreeWinSize=80
" nerdtree ignore filetypes
let g:NERDTreeIgnore = ['\.pyc$', '\.swp$', '__pycache__']
"""SYSTEM CLIPBOARD COPY & PASTE SUPPORT
set pastetoggle=<F2> "F2 before pasting to preserve indentation

" auto toggle set paste and set nopaste
" link: https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction



"""Copy paste to/from clipboard
" vnoremap <C-c> "*y
" map <silent><Leader>p :set paste<CR>o<esc>"*]p:set nopaste<cr>"
" map <silent><Leader><S-p> :set paste<CR>O<esc>"*]p:set nopaste<cr>"
""" map :cn and :cp keys
" nnoremap <silent> m :cnext <CR>
" nnoremap <silent> M :cprevious <CR>
" nnoremap <silent> m m
" nnoremap <silent> M M
""" set numbering in editor
" set number

" turn hybrid line numbers on
set number relativenumber

" nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
" nnoremap  <silent>   <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
" nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:next<CR>
" nnoremap  <silent>   <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:previous<CR>
nnoremap <C-s> :w <CR>
inoremap <C-s> <Esc>`^:w<CR>



" make backspace work like normal backspace in the insert mode "
set backspace=2

" fix gruvbox not show problem
" run 'export TERM=xterm-256color' in terminal
set t_ut=

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'preservim/nerdtree'
Plug 'wellle/context.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neoclide/coc.nvim', {'tags': 'v0.0.82'}
Plug 'gruvbox-community/gruvbox'
Plug 'lervag/vimtex'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'dense-analysis/ale'
Plug 'mbbill/undotree'
Plug 'airblade/vim-rooter'
Plug 'vim-python/python-syntax'
Plug 'puremourning/vimspector'
Plug 'AndrewRadev/linediff.vim'
Plug 'goerz/jupytext.vim'
Plug 'bfrg/vim-c-cpp-modern'
call plug#end()
" Plug 'tpope/vim-repeat'
" Plug 'vim-airline/vim-airline'
" Plug 'scrooloose/nerdtree'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neoclide/coc.nvim', {'tags': 'v0.0.82'}
" :CocInstall coc-json coc-vimlsp coc-pyright
" Plug 'gruvbox-community/gruvbox'
" Plug 'jbgutierrez/vim-better-comments'
" Plug 'mg979/vim-visual-multi'
" Plug 'glench/vim-jinja2-syntax'

" Plug 'ludovicchabant/vim-gutentags'
" let g:gutentags_project_root = ['~/workspace/TAIRCraft-autobuild/']

" Plug 'craigemery/vim-autotag'
" autotag config:
" let g:autotagStartMethod='fork'

set background=dark

" colorscheme ron
" colorscheme peachpuff
colorscheme gruvbox

" context.vim
let g:context_enabled = 1
let g:context_highlight_tag = '<hide>'
let g:context_border_char = '='

"shortcuts gaip*, # for align ','
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"fzf config
" Preview window on the up/down/right/left side of the window with xx% height,
" hidden by default, ctrl-/ to toggle
" let g:fzf_preview_window = ['up:40%:hidden', 'ctrl-/']
let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-/']
" let g:fzf_layout = {'up': '40%'}
let g:fzf_layout = {'window': {'width': '110%', 'height': '25%'}}

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" mouse scroll
set mouse=a

" python syntax config:
let g:python_highlight_all = 1
let g:python_highlight_space_errors = 0


" coc config
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

let g:coc_disable_startup_warning = 1

" try to solve cursor disapper problem
let g:coc_disable_transparent_cursor = 1

" fix for colorscheme
autocmd ColorScheme * hi CocMenuSel ctermbg=237 guibg=#13354A ctermfg=Blue guifg=#15aabf

" for debug coc
" let g:node_client_debug = 1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" zoom out and zoom in for diffmode
noremap <silent><space>li :windo set wrap foldcolumn=0 signcolumn=no nonumber norelativenumber<CR>
noremap <silent><space>lo :windo set nowrap signcolumn=yes number relativenumber<CR>

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  <space>a
" Manage extensions.
nnoremap <silent><nowait> <space>e  <space>e
" Show commands.
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>c  <space>c
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  <space>o
" Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>s  <space>s
" Do default action for next item.
nnoremap <silent><nowait> <space>j  <space>j
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  <space>k
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  <space>p

" for ale
let g:ale_enabled = 0 " 1 for enbale
noremap <silent><space>la :ALEToggle<CR>
let g:ale_linters = {'python': ['pylint', 'flake8']}
let g:ale_fixers = {'*': [], 'python': ['black', 'autopep8','yapf', 'isort']}
let g:ale_python_autopep8_options = '--aggressive --experimental'
let g:ale_python_black_options = '--experimental-string-processing'
let g:ale_fix_on_save = 0 " 1
let g:ale_disable_lsp = 1
" :CocConfig and add 'diagnostic.displayByAle': true to your settings.
let g:ale_open_list = 1
nnoremap <silent><nowait> ]e <Plug>(ale_previous_wrap)
nnoremap <silent><nowait> [e <Plug>(ale_next_wrap)


" for vimtex
" for all options, see :help vimtex-options
" VimTeX uses latexmk as the default compiler backend. 
" If you use it, you don't need to configure anything. 
" let g:vimtex_compiler_method =
let g:vimtex_view_method = 'skim'
" Value 1 allows forward search after every successful compilation
let g:vimtex_view_skim_sync = 1 
" Value 1 allows change focus to skim after command `:VimtexView` is given
let g:vimtex_view_skim_activate = 1 
" let g:vimtex_compiler_silent = 1

" not auto compile after save
" let g:vimtex_compiler_latexmk = {'continuous': 0}
" add -shell-escape for minted latex package 
let g:vimtex_compiler_latexmk = {
    \ 'build_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 0,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

" Don't open QuickFix for warning messages if no errors are present
let g:vimtex_quickfix_open_on_warning = 0  

" change the size of table of content window
let g:vimtex_toc_config = {'split_width': 80}

" autoload file
set autoread
au CursorHold * checktime 

" vimspector
let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_install_gadgets = [ 'debugpy']
let g:vimspector_sidebar_width = 40 " 50
let g:vimspector_bottombar_height = 5 " 10
let g:vimspector_code_minwidth = 85 " 82
let g:vimspector_terminal_maxwidth = 30 " 80
let g:vimspector_terminal_minwidth = 1 " 10
let g:vimspector_enable_winbar=0
let g:vimspector_enable_auto_hover=1
nmap <F7> :VimspectorReset<CR>
nmap <F5> <Plug>VimspectorContinue
nmap <F3> <Plug>VimspectorStop
nmap <F4> <Plug>VimspectorRestart
nmap <F6> <Plug>VimspectorPause
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <leader><F9> <Plug>VimspectorToggleConditionalBreakpoint
nmap <F8> <Plug>VimspectorAddFunctionBreakpoint
nmap <leader><F8> <Plug>VimspectorRunToCursor
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
nmap <F12> <Plug>VimspectorStepOut
" mnemonic 'di' = 'debug inspect' (pick your own, if you prefer!)
" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval
nmap <LocalLeader><F11> <Plug>VimspectorUpFrame
nmap <LocalLeader><F12> <Plug>VimspectorDownFrame
nmap <LocalLeader>B     <Plug>VimspectorBreakpoints
nmap <LocalLeader>D     <Plug>VimspectorDisassemble

" set gui cursor to not blink
" Disable all blinking:
set guicursor+=a:blinkon0
" Remove previous setting:
" set guicursor-=a:blinkon0
" Restore default setting:
" set guicursor&

" jupytext
let g:jupytext_enable = 1
let g:jupytext_command = 'jupytext'
let g:jupytext_fmt = 'py' " md, py
let g:jupytext_to_ipynb_opts = '--to=ipynb --update'
let g:jupytext_print_debug_msgs = 0
" let g:jupytext_filetype_map = {}
