" Use Vim settings, rather than Vi settings.
if &compatible
  set nocompatible
endif

" want Vim to use these default values.
if exists('skip_defaults_vim')
  finish
endif

set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set directory-=.                                             " don't store swapfiles in the current directory
set encoding=utf-8
set expandtab                                                " expand tabs to spaces
set ignorecase                                               " case-insensitive search
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set smartcase                                                " case-sensitive search if any caps
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set tabstop=8                                                " actual tabs occupy 8 characters
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

" Settings for Codeium
let g:codeium_enabled = v:true
let g:codeium_idle_delay = 250

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

set history=200         " keep 200 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set ttimeout            " time out for key codes
set ttimeoutlen=100     " wait up to 100ms after Esc for special key

" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
endif

" Install vim-plug if it doesn't exist (optimized)
function! InstallVimPlugIfNeeded()
    let autoload_dir = expand('~/.vim/autoload')
    let plug_vim_path = autoload_dir . '/plug.vim'

    " Check if vim-plug is installed
    if !filereadable(plug_vim_path)
        " If not installed, install silently
        if has('unix')
            silent execute '!curl -fLo ' . plug_vim_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1'
        elseif has('win32') || has('win64')
            silent execute '!powershell -command "iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni ' . $HOME . '/vimfiles/autoload/plug.vim -Force" >$null 2>&1'
        else
            echoerr 'Unsupported platform'
            return
        endif
    endif
endfunction

call InstallVimPlugIfNeeded()

" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
  " Revert with ":syntax off".
  syntax on
  set number

  " Highlight strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
endif

  " Only do this part when compiled with support for autocommands.
  if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":augroup vimStartup | au! | augroup END"
  augroup vimStartup
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

      augroup END

      endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif

" Only set working directory when it actually changes
let s:last_dir = ''
autocmd BufEnter * 
    \ let l:current_dir = expand('%:p:h') | 
    \ if l:current_dir !=# s:last_dir | 
    \     lcd %:p:h | 
    \     let s:last_dir = l:current_dir | 
    \ endif

" Only sync syntax when needed and for large files
autocmd BufEnter * if getfsize(expand('%')) < 100000 && &filetype !=# '' | syntax sync fromstart | endif

" Setting folding method to 'indent'
:setlocal foldmethod=manual

map T :term

" fuzzy finder
fu! Fuzzy()
    enew
    read !find -type f
    cnoremap <buffer> / \/
    nnoremap <buffer> <cr> gf:bd! #<cr>
endf

" Mappings for markdown-preview
let vim_markdown_preview_hotkey='<C-m>'

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'Y' | call system(s:clip, @0) | endif
    augroup END
endif

" suppress Coc plugin's warning about outdated Vim version


" Settings for Coc
let g:coc_disable_startup_warning = 1
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm(): "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <c-@> coc#refresh()

" Optional settings for Black, uncomment and set as needed
let g:black_fast = 1
let g:black_linelength = 88
let g:black_skip_string_normalization = 0

" Mappings for Black with debugging
" Add mappings with debugging messages
autocmd FileType python nnoremap <buffer> <silent> <C-k> :echo "Running Black on the entire file..."<CR> :!black --color --quiet -l 78 % <CR>

" Highlights words that exceed set line length
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 78)
