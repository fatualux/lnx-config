# Smart Completion - Quick Start

## What It Does

**Automatic tab completion for command options** from `--help` and `man` pages.

```bash
docker --<TAB>          # Shows all docker options
git --<TAB>             # Shows all git options  
git checkout <TAB>      # Shows branches
```

## Features

✅ **Universal** - Works with any command  
✅ **Smart Git** - Branches, subcommands, options  
✅ **Cached** - 24-hour cache for performance  
✅ **No setup** - Just use it!  

## Usage

### Basic
```bash
# After sourcing main.sh
ls --<TAB>              # Lists: --all, --almost-all, etc.
python --<TAB>          # Lists python options
```

### Git Specific
```bash
git <TAB>               # Subcommands: add, commit, push, etc.
git checkout <TAB>      # Branches: main, develop, feature/*, etc.
git merge <TAB>         # Branches for merging
git --<TAB>             # Global options: --version, --help, etc.
```

### Clearing Cache
```bash
# Clear one command's cache
rm ~/.cache/bash-smart-complete/docker.opts

# Clear all caches
rm -rf ~/.cache/bash-smart-complete/
```

## How It Works

1. You press TAB after typing `-`
2. System checks if command has `--help` or `man` page
3. Options extracted and cached to `~/.cache/bash-smart-complete/`
4. First run ~100-500ms (extraction), then ~10ms (cached)

## Files

- **Source:** [completion/autocomplete.sh](../completion/autocomplete.sh)
- **Tests:** [tests/test_autocomplete.sh](../../../tests/test_autocomplete.sh)
- **Docs:** [docs/completion.md](completion.md)

## Troubleshooting

**No options showing?**
```bash
docker --help           # Verify command supports --help
man docker              # Check if man page exists
```

**Options seem outdated?**
```bash
rm ~/.cache/bash-smart-complete/docker.opts  # Clear cache
```

**Git branches not completing?**
```bash
git branch -a           # Test git works
complete | grep _smart_git_complete  # Verify registered
```

For more details, see [docs/completion.md](completion.md).
