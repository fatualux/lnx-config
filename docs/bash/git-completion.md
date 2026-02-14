# Git Advanced Completion Module

## Overview

The Git Advanced Completion module (`git-completion.sh`) provides comprehensive bash autocompletion for git commands with intelligent suggestions for branches, remotes, tags, and command options.

## Features

### Local & Remote Branch Completion
```bash
git checkout [TAB]              # Shows local branches
git checkout origin/[TAB]       # Shows remote branches
git merge [TAB]                 # All branches available
git rebase [TAB]                # All branches available
git reset [TAB]                 # All branches available
```

### Commit Message Quotes
```bash
git commit -m [TAB]             # Automatically handles quoting
git commit --message [TAB]      # Full option name support
```

### Command Option Completion
```bash
git add [TAB]                   # Modified files
git add -[TAB]                  # --all --verbose --force --update --patch etc.
git commit -[TAB]               # --message --amend --no-verify --author etc.
git push -[TAB]                 # --force --all --tags --dry-run etc.
git pull -[TAB]                 # --rebase --ff-only --verify-signatures etc.
```

### Stash Completion
```bash
git stash [TAB]                 # list, save, push, pop, apply, drop, clear
git stash pop [TAB]             # Available stash entries (stash@{0}, stash@{1}, etc.)
git stash show [TAB]            # Stash references for viewing
```

### Remote Completion
```bash
git push [TAB]                  # All configured remotes (origin, upstream, etc.)
git pull [TAB]                  # All configured remotes
git fetch [TAB]                 # All configured remotes
```

### Tag Completion
```bash
git tag [TAB]                   # All existing tags
git show [TAB]                  # Tag names, commit hashes
git checkout [TAB]              # Tags as branch-like references
```

## Supported Commands

| Command | Features |
|---------|----------|
| `add` | Modified files + options (--patch, --force, --update) |
| `checkout` | Local/remote branches + options (--track, --detach) |
| `commit` | Options (--message, --amend, --no-verify, --author) |
| `branch` | All branches + options (--list, --delete, --track) |
| `merge` | Branches + options (--no-ff, --squash, --edit) |
| `push` | Remotes + options (--force, --all, --tags, --dry-run) |
| `pull` | Remotes + options (--rebase, --ff-only, --squash) |
| `fetch` | Remotes + options (--all, --prune, --tags, --depth) |
| `reset` | Branches + options (--soft, --mixed, --hard) |
| `rebase` | Branches + options (--interactive, --autosquash, --force) |
| `tag` | Tags + options (--annotate, --sign, --delete) |
| `stash` | Subcommands + stash references + options |
| `remote` | Remotes + subcommands (add, remove, rename, show) |
| `config` | Options (--local, --global, --system, --list) |
| `log` | Options (--oneline, --graph, --all, --author) |
| `diff` | Options (--stat, --patch, --color, --cached) |
| `show` | Commits/tags + options (--stat, --patch, --format) |
| `clone` | Options (--depth, --branch, --single-branch) |
| `status` | Options (--short, --porcelain, --untracked-files) |

## Usage Examples

### Branch Switching
```bash
$ git checkout fea[TAB]
feature-new-api
feature-refactor
feature-ui-redesign
```

### Commit with Autofill
```bash
$ git commit -m "Fix bug in [TAB]
# Provides intelligent quoting for commit messages
```

### Remote Branch Management
```bash
$ git checkout --track origin/deve[TAB]
# Autocompletes with origin/develop and other remote branches
```

### Merge with Options
```bash
$ git merge -[TAB]
--abort           --autosquash      --commit          --continue        --edit
--edit-todo       --ff-only         --ff              --interactive     --merge
--no-commit       --no-edit         --quiet           --rebase          --signoff
--squash          --stat            --strategy        --verbose
```

### Push with Safety
```bash
$ git push --[TAB]
--all             --atomic          --delete          --dry-run         --force
--force-with-lease --no-verify      --porcelain       --prune           --quiet
--signed          --tags            --verbose
```

### Stash Management
```bash
$ git stash pop st[TAB]
stash@{0}
stash@{1}
stash@{2}
```

## Installation

The module is automatically loaded when bash initializes through:
- `.bashrc` → `~/.lnx-config/configs/bash/main.sh`
- Main config → completion directory loop
- All `*.sh` files in `completion/` are sourced

### Manual Activation
If needed, manually source the module:
```bash
source ~/.lnx-config/configs/bash/completion/git-completion.sh
```

## Implementation Details

### Helper Functions

**Branch Retrieval:**
- `_git_get_local_branches()` - Local branch refs
- `_git_get_remote_branches()` - Remote branch refs
- `_git_get_all_branches()` - Combined local + remote

**Other References:**
- `_git_get_tags()` - All git tags
- `_git_get_remotes()` - Configured remotes
- `_git_get_stashes()` - Stash list entries
- `_git_get_subcommands()` - All git subcommands
- `_git_get_commits()` - Recent commits for reference
- `_git_get_modified_files()` - Staged/unstaged files

### Command-Specific Functions

Each git command has a dedicated completion function:
- `_git_complete_add()` - Add command
- `_git_complete_checkout()` - Checkout command
- `_git_complete_commit()` - Commit command
- `_git_complete_branch()` - Branch command
- And 14+ more...

### Main Dispatcher

`_git_advanced_complete()` routes to appropriate command handler based on:
1. Current word being completed (`$cur`)
2. Previous word (`$prev`) for option-specific handling
3. Main git subcommand detected from words array

## Performance Considerations

- Uses `git for-each-ref` for efficient branch listing (faster than `git branch`)
- Caches are not used (real-time git data) for accuracy
- Option lists are hardcoded for instant response
- Only runs git commands when completing argument values, not options

## Troubleshooting

### Completions Not Working

1. **Verify module is loaded:**
   ```bash
   declare -f _git_advanced_complete
   # Should output the function definition
   ```

2. **Check bash completion is enabled:**
   ```bash
   shopt -s progcomp
   # Should be on (completer will show: progcomp = on)
   ```

3. **Force reload:**
   ```bash
   source ~/.bashrc
   # Or: source ~/.lnx-config/configs/bash/completion/git-completion.sh
   ```

### Git Commands Not Found

Ensure git is installed and in PATH:
```bash
command -v git
# Should output git executable path
```

### Slow Completions

If completions are slow:
1. Large number of branches might slow `git for-each-ref`
2. Consider using `--depth` for shallow clones in large repos
3. Optimize git config: `git config --global gc.autodetach true`

## Testing

Run the test suite:
```bash
bash tests/test_git_completion.sh
```

Tests verify:
- All helper functions exist and work
- Command-specific completion functions are defined
- Options are correctly listed
- Main completion dispatcher is registered

Expected output: All 19+ tests passing

## File Location

- **Module:** `~/.lnx-config/configs/bash/completion/git-completion.sh`
- **Tests:** `~/.lnx-config/tests/test_git_completion.sh`
- **Documentation:** `~/.lnx-config/docs/bash/completion.md`

## Integration with Other Completion Systems

This module is designed to work independently but coordinates with:
- **Smart completion** (`autocomplete.sh`) - Provides fallback/enhancement
- **Readline configuration** - Uses standard bash completion arrays
- **Custom aliases** - Works seamlessly with aliased git commands

## Extending the Module

To add completion for a custom git command:

1. Create a completion function:
```bash
_git_complete_mycommand() {
    local cur="$1"
    local opts="--option1 --option2 --option3"
    
    if [[ "$cur" == -* ]]; then
        echo "$opts"
        return
    fi
    
    # Custom logic for non-option arguments
    echo "some-value"
}
```

2. Add to dispatcher in `_git_advanced_complete()`:
```bash
mycommand) completions=$(_git_complete_mycommand "$cur") ;;
```

3. Test and verify:
```bash
bash tests/test_git_completion.sh
```

## Version

- **Module Version:** 1.0.0
- **Last Updated:** 2026-01-31
- **Compatibility:** Bash 4.0+ with `bash-completion` library or native completion support
