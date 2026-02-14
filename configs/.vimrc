function! SourceConfigDir(dir)
    let l:full_path = expand('~/.lnx-config/configs/vim/' . a:dir)
    for file in glob(l:full_path . '/*.vim', 1, 1)
        execute 'source ' . fnameescape(file)
    endfor
endfunction

" Source vim configuration from lnx-config installation
call SourceConfigDir('config')
call SourceConfigDir('plugins')
