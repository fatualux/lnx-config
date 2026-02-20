# Directory Structure

```
./
├── applications/
│   ├── apps.txt
│   ├── install_apps.sh
│   ├── install_errors.log
│   └── install.log
├── configs/
│   ├── bash/
│   │   ├── aliases/
│   │   │   ├── alias.sh
│   │   │   └── work-alias.sh
│   │   ├── completion/
│   │   │   └── autocomplete.sh
│   │   ├── config/
│   │   │   ├── env_vars.sh
│   │   │   ├── history.sh
│   │   │   ├── hist-token.sh
│   │   │   ├── readline.sh
│   │   │   └── theme.sh
│   │   ├── core/
│   │   │   ├── colors.sh
│   │   │   ├── logger.sh
│   │   │   └── spinner.sh
│   │   ├── functions/
│   │   │   ├── aliases/
│   │   │   │   ├── list_all_aliases.sh
│   │   │   │   └── list_my_aliases.sh
│   │   │   ├── development/
│   │   │   │   ├── code_directory.sh
│   │   │   │   └── git-utils.sh
│   │   │   ├── docker/
│   │   │   │   ├── docker_compose_file.sh
│   │   │   │   ├── docker_compose_wrapper.sh
│   │   │   │   ├── docker_container_prune_force.sh
│   │   │   │   ├── docker_network_prune_force.sh
│   │   │   │   ├── docker_system_prune_force.sh
│   │   │   │   └── kill_docker_containers.sh
│   │   │   ├── filesystem/
│   │   │   │   ├── clear_python_caches.sh
│   │   │   │   └── remove_zone_info.sh
│   │   │   └── music/
│   │   │       ├── add_track_to_playlist.sh
│   │   │       ├── play_music_shuffle.sh
│   │   │       └── remove_currently_playing_track.sh
│   │   ├── integrations/
│   │   │   ├── cd-activate.sh
│   │   │   ├── docker.sh
│   │   │   ├── fzf_search.sh
│   │   │   └── mc-autocomplete.sh
│   │   ├── main.sh
│   │   └── themes/
│   │       ├── compact.sh
│   │       ├── default.sh
│   │       ├── developer.sh
│   │       ├── minimal.sh
│   │       └── rainbow.sh
│   ├── joshuto/
│   │   ├── bookmarks.toml
│   │   ├── joshuto.toml
│   │   ├── keymap.toml
│   │   ├── mimetype.toml
│   │   └── theme.toml
│   ├── mpv/
│   │   ├── input.conf
│   │   ├── mpv.conf
│   │   └── scripts/
│   │       └── pretty-progress.lua
│   ├── nvim/
│   │   ├── colors/
│   │   ├── config/
│   │   │   ├── cust_func.lua
│   │   │   ├── general.lua
│   │   │   ├── keybindings.lua
│   │   │   ├── main.lua
│   │   │   ├── plugins.lua
│   │   │   ├── statusline.lua
│   │   │   ├── theme.lua
│   │   │   └── wildmenu.lua
│   │   └── init.lua
│   ├── ranger/
│   │   ├── bookmarks.conf
│   │   ├── keys.conf
│   │   ├── rc.conf
│   │   ├── rifle.conf
│   │   └── scope.sh
│   └── vim/
│       ├── autoload/
│       │   ├── plug.vim
│       │   └── togglebg.vim
│       ├── colors/
│       │   ├── badwolf.vim
│       │   ├── jellybeans.vim
│       │   └── solarized.vim
│       └── config/
│           ├── bash_completion.vim
│           ├── cust_func.vim
│           ├── general.vim
│           ├── keybindings.vim
│           ├── main.sh
│           ├── plugins.vim
│           ├── statusline.vim
│           ├── theme.vim
│           └── wildmenu.vim
├── docs/
│   ├── applications.md
│   ├── bash/
│   │   ├── docs/
│   │   │   ├── aliases.md
│   │   │   ├── CHANGELOG.md
│   │   │   ├── completion.md
│   │   │   ├── COMPLETION_QUICKSTART.md
│   │   │   ├── config.md
│   │   │   ├── core.md
│   │   │   ├── docs.md
│   │   │   ├── functions/
│   │   │   │   ├── aliases.md
│   │   │   │   ├── development.md
│   │   │   │   ├── docker.md
│   │   │   │   ├── filesystem.md
│   │   │   │   └── music.md
│   │   │   ├── functions.md
│   │   │   ├── integrations.md
│   │   │   ├── OVERVIEW.md
│   │   │   ├── README.md
│   │   │   ├── STRUCTURE.md
│   │   │   ├── tests/
│   │   │   │   └── logs.md
│   │   │   ├── tests.md
│   │   │   └── themes.md
│   │   └── functions/
│   │       └── OVERVIEW.md
│   ├── copilot-instructions.md
│   ├── nvim.md
│   ├── nvim-structure.md
│   ├── STRUCTURE.md
│   └── tests.md
├── LICENSE
├── main.sh
├── quick-reference.sh
├── run_all_tests.sh
├── scripts/
│   └── make-dir-tree.sh
├── src/
│   ├── colors.sh
│   ├── logger.sh
│   └── spinner.sh
└── tests/
    ├── logs/
    │   ├── test_modules_20260130_182527.log
    │   ├── test_modules_20260130_182636.log
    │   ├── test_modules_20260130_184145.log
    │   ├── test_modules_20260130_185209.log
    │   ├── test_modules_20260130_185523.log
    │   ├── test_modules_20260130_185609.log
    │   ├── test_modules_20260130_214723.log
    │   ├── test_modules_20260130_214953.log
    │   ├── test_modules_20260130_230037.log
    │   ├── test_modules_20260131_082320.log
    │   ├── test_modules_20260131_082336.log
    │   ├── test_modules_20260131_082356.log
    │   └── test_modules_20260131_082400.log
    ├── run_tests_with_spinners.sh
    ├── test_aliases.sh
    ├── test_autocomplete.sh
    ├── test_docker.sh
    ├── test_filesystem.sh
    ├── test_integration.sh
    ├── test_make_dir_tree.sh
    ├── test_modules.sh
    ├── test_music.sh
    ├── test_readline.sh
    ├── test_themes.sh
    └── test_utils.sh
```
