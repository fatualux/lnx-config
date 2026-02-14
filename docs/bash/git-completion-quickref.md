# Git Autocompletion Quick Reference

## Quick Start

After loading your `.bashrc`, git autocompletion is automatically available. Start typing a git command and press `[TAB]`:

```bash
# Branch completion
git checkout [TAB]              # Shows all local and remote branches
git checkout feat[TAB]          # Auto-completes matching branches

# Option completion
git commit -[TAB]               # Shows all available options
git push --[TAB]                # Shows push-specific options

# Stash completion
git stash [TAB]                 # Shows: list, save, push, pop, apply, drop, clear
git stash pop st[TAB]           # Completes stash references
```

## Common Workflows

### Checking Out a Branch
```bash
$ git checkout [TAB]
feature-new-login    feature-refactor     feature-ui-update
main                 origin/develop       origin/feature-new-login
origin/feature-refactor origin/feature-ui-update origin/main
```

### Making a Commit
```bash
$ git commit -[TAB]
--all                     --amend                   --author=
--date=                   --edit                    --message=
--no-edit                 --no-verify               --patch
--quiet                   --reset-author            --shortstat
--signoff                 --stat                    --verbose
```

### Pushing with Options
```bash
$ git push --[TAB]
--all                --atomic              --delete          --dry-run
--force              --force-with-lease    --no-verify       --porcelain
--prune              --quiet               --set-upstream    --tags
--verbose
```

## Key Features

- **Local & Remote Branches**: Complete branch names for checkout, merge, reset, rebase
- **Command Options**: Smart option completion with `--force`, `--no-verify`, `--dry-run`, etc.
- **Stash References**: Complete stash IDs like `stash@{0}`, `stash@{1}`
- **Tags**: Auto-complete tag names for show, checkout, tag commands
- **Remotes**: Complete remote names for push, pull, fetch
- **Files**: Modified files for git add

## File Locations

- **Module**: `~/.lnx-config/configs/bash/completion/git-completion.sh`
- **Tests**: `~/.lnx-config/tests/test_git_completion.sh`
- **Full Docs**: `~/.lnx-config/docs/bash/git-completion.md`
