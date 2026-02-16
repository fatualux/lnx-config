" Show current git branch (optimized with caching)
let b:git_current_branch = ''
let s:git_branch_cache = {}
let s:git_branch_cache_time = {}
let s:cache_duration = 30 " cache for 30 seconds

fun! GitBranch()
    let l:dir = expand('%:p:h')
    let l:current_time = localtime()
    
    " Check cache first
    if has_key(s:git_branch_cache, l:dir) && 
     \ has_key(s:git_branch_cache_time, l:dir) &&
     \ (l:current_time - s:git_branch_cache_time[l:dir]) < s:cache_duration
        let b:git_current_branch = s:git_branch_cache[l:dir]
        return
    endif
    
    " Only run git command if we're in a git repo
    if isdirectory(l:dir . '/.git')
        let l:cmd = 'git -C ' . l:dir . ' branch --show-current 2>/dev/null'
        let l:branch = trim(system(l:cmd))
        
        " Cache the result
        let s:git_branch_cache[l:dir] = l:branch
        let s:git_branch_cache_time[l:dir] = l:current_time
        let b:git_current_branch = l:branch
    else
        let b:git_current_branch = ''
    endif
endfun

augroup GitBranch
    autocmd!
    " Only update on directory changes, not every buffer change
    autocmd DirChanged * call GitBranch()
    autocmd BufEnter * if getcwd() !=# expand('%:p:h') | call GitBranch() | endif
augroup END

set rulerformat=%32(%=%{b:git_current_branch}%=%)\ %8l,%-6(%c%V%)%=%4p%%\ %P
