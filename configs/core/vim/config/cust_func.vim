" show git branch
fun! GitBranch(file)
    let l:dir = fnamemodify(system('readlink -f ' . a:file), ':h')
    let l:cmd = 'git -C ' . l:dir . ' branch --show-current 2>/dev/null'
    let b:git_current_branch = trim(system(l:cmd))
endfun

augroup GitBranch
    autocmd!
    autocmd BufEnter,ShellCmdPost,FileChangedShellPost * call GitBranch(expand('%'))
augroup END

" Autodetect file changes when written and git commit
function! AutoGit()
  let file_name = expand('%')
  let choice = inputdialog('Changes detected in ' . file_name . '. Do you want to add the file to the repository? ')
  if choice == 'y' || choice == 'Y' || choice == 'yes' || choice == 'Yes' || choice == 'YES'
    execute ':!git pull && git add %'
    let additional_comments = inputdialog('Add additional comments (leave empty to skip): ')
    if !empty(additional_comments)
      let commit_message = additional_comments
      let escaped_commit_message = substitute(commit_message, '"', '\"', 'g')
      execute ':!git commit -m """' . escaped_commit_message . '"""'
      let push_choice = inputdialog('Commit successful. Do you want to push the changes? ')
      if push_choice == 'Yes' || push_choice == 'yes' || push_choice == 'y' || push_choice == 'Y' || push_choice == 'YES'
        execute ':!git push'
      endif
    endif
  elseif choice == 'n' || choice == 'N' || choice == 'no' || choice == 'No' || choice == 'NO'
    return
  endif
endfunction

autocmd BufWritePost * call AutoGit()

map <C-g> :call ToggleAutoGit()<CR>

let g:detect_line_changes_enabled = 1

function! ToggleAutoGit()
  if g:detect_line_changes_enabled
    autocmd! BufWritePost *
    let g:detect_line_changes_enabled = 0
    echo "AutoGit disabled"
  else
    autocmd BufWritePost * call AutoGit()
    let g:detect_line_changes_enabled = 1
    echo "AutoGit enabled"
  endif
endfunction

augroup GitBranch
    autocmd!
    autocmd BufEnter,ShellCmdPost,FileChangedShellPost * call GitBranch(expand('%'))
augroup END

map <C-g> :call ToggleAutoGit()<CR>

let g:detect_line_changes_enabled = 1

function! ToggleAutoGit()
  if g:detect_line_changes_enabled
    autocmd! BufWritePost *
    let g:detect_line_changes_enabled = 0
    echo "AutoGit disabled"
  else
    autocmd BufWritePost * call AutoGit()
    let g:detect_line_changes_enabled = 1
    echo "AutoGit enabled"
  endif
endfunction

" MULTILINEFIND

function FindChar()
    let c = nr2char( getchar() )
    let match = search('\V' . c)
endfunction

map <C-l> :call FindChar()<CR>

function! WSLYank()
    let winclip = '/mnt/c/Windows/System32/clip.exe'
    if executable(winclip)
        " Yank the selected text into the default register
        normal! gv"zy
        let contents = getreg('z')  " Get the contents of the 'z' register
        if empty(contents)
            echo "Register is empty, nothing to yank"
            return
        endif
        " Escape contents and handle newlines properly
        let escaped_contents = substitute(contents, '\n', '\r\n', 'g')
        let cmd = 'echo ' . shellescape(escaped_contents) . ' | ' . winclip
        call system(cmd)
        if v:shell_error
            echo "Error copying to clipboard"
        else
            echo "Copied to clipboard"
        endif
    else
        echo "Clipboard tool (clip.exe) not found"
    endif
endfunction

" Map Ctrl+C to call the WSLYank function
vmap <C-c> :call WSLYank()<CR>
