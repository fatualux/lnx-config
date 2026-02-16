" Show current git branch (optimized with caching)
let b:git_current_branch = ''
let s:git_branch_cache = {}
let s:git_branch_cache_time = {}
let s:cache_duration = 30 " cache for 30 seconds - balances performance and responsiveness
let s:max_cache_size = 50 " maximum number of directories to cache to prevent memory growth

" Cache cleanup function to prevent memory leaks
function! s:cleanup_git_cache()
    let l:current_time = localtime()
    let l:keys_to_remove = []
    
    " Remove expired entries
    for [l:dir, l:timestamp] in items(s:git_branch_cache_time)
        if (l:current_time - l:timestamp) >= s:cache_duration
            call add(l:keys_to_remove, l:dir)
        endif
    endfor
    
    " Remove oldest entries if cache is too large
    if len(s:git_branch_cache) > s:max_cache_size
        let l:sorted_keys = sort(keys(s:git_branch_cache_time), 's:compare_timestamp')
        let l:excess = len(s:git_branch_cache) - s:max_cache_size
        for i in range(l:excess)
            call add(l:keys_to_remove, l:sorted_keys[i])
        endfor
    endif
    
    " Actually remove the entries
    for l:key in l:keys_to_remove
        call remove(s:git_branch_cache, l:key)
        call remove(s:git_branch_cache_time, l:key)
    endfor
endfunction

" Helper function to sort by timestamp (oldest first)
function! s:compare_timestamp(key1, key2)
    return s:git_branch_cache_time[a:key1] - s:git_branch_cache_time[a:key2]
endfunction

fun! GitBranch()
    let l:dir = expand('%:p:h')
    let l:current_time = localtime()
    
    " Cleanup cache periodically (every 10 calls to avoid overhead)
    if !exists('s:cleanup_counter')
        let s:cleanup_counter = 0
    endif
    let s:cleanup_counter += 1
    if s:cleanup_counter >= 10
        call s:cleanup_git_cache()
        let s:cleanup_counter = 0
    endif
    
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
