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
- [.github.md](.github.md)
- [aliases.md](aliases.md)
- [config.md](config.md)
- [core.md](core.md)
- [docs.md](docs.md)
- [functions.md](functions.md)
- [functions/aliases.md](functions/aliases.md)
- [functions/development.md](functions/development.md)
- [functions/docker.md](functions/docker.md)
- [functions/filesystem.md](functions/filesystem.md)
- [functions/music.md](functions/music.md)
- [integrations.md](integrations.md)
- [tests.md](tests.md)
- [tests/logs.md](tests/logs.md)
- [themes.md](themes.md)

## Notes
- The loader in main.sh auto-sources all .sh files in each category.
- Tests can be run from the project root via tests/run_tests_with_spinners.sh.
- The directory tree is generated with scripts/make-dir-tree.sh.
