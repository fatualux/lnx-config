" Show current git branch
let b:git_current_branch = ''

fun! GitBranch(file)
    let l:dir = fnamemodify(system('readlink -f ' . a:file), ':h')
    let l:cmd = 'git -C ' . l:dir . ' branch --show-current 2>/dev/null'
    let b:git_current_branch = trim(system(l:cmd))
endfun

augroup GitBranch
    autocmd!
    autocmd BufEnter,ShellCmdPost,FileChangedShellPost * call GitBranch(expand('%'))
augroup END

set rulerformat=%32(%=%{b:git_current_branch}%=%)\ %8l,%-6(%c%V%)%=%4p%%\ %P
