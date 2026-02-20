# Bash Configuration Documentation

See the full directory tree in [STRUCTURE.md](STRUCTURE.md).

## Project Purpose
This project provides a modular Bash configuration system that loads core utilities, configuration, aliases, integrations, and categorized functions from a structured directory layout.

## How to Use
1. Source the loader:
   - Use: source ~/.config/bash/main.sh
2. Optional: choose a theme before sourcing:
   - Set BASH_THEME to one of: default, minimal, compact, developer, rainbow

## Directory Overviews
- [modules-overview.md](modules-overview.md) - Complete overview of all bash modules
- [.github.md](.github.md)
- [completion.md](completion.md)
- [config.md](config.md)
- [docs.md](docs.md)
- [functions.md](functions.md)
- [functions/aliases.md](functions/aliases.md)
- [functions/development.md](functions/development.md)
- [functions/docker.md](functions/docker.md)
- [functions/filesystem.md](functions/filesystem.md)
- [functions/music.md](functions/music.md)
- [tests.md](tests.md)
- [tests/logs.md](tests/logs.md)
- [COMPLETION_QUICKSTART.md](COMPLETION_QUICKSTART.md)

## Notes
- The loader in main.sh auto-sources all .sh files in each category.
- Tests can be run from the project root via tests/run_tests_with_spinners.sh.
- The directory tree is generated with scripts/make-dir-tree.sh.
