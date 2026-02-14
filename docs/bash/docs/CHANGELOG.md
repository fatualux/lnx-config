# Changelog

All notable changes to this project are documented here.

## v1.0.6 - 2026-01-30
### Added
- History search bindings via config/hist-token.sh.
### Changed
- Documentation for history navigation and config overview.
- Updated directory structure snapshot.

## v1.0.5 - 2026-01-30
### Enhanced
- Smart completion system with intelligent option extraction from --help/man pages
- 24-hour option caching for performance optimization
- Git special handling: subcommands, branch completion, global options
- Comprehensive caching system with configurable TTL
- Better error handling and fallback mechanisms
### Added
- docs/completion.md - Complete completion system documentation
- Tests for option extraction, caching, and git features
- Cache management and troubleshooting guides

## v1.0.4 - 2026-01-30
### Changed
- Autocompletion now auto-registers for functions under functions/.
- Optional alias completion support via BASH_CONFIG_COMPLETION_INCLUDE_ALIASES.
### Added
- Autocomplete tests.

## v1.0.3 - 2026-01-30
### Changed
- Removed syntax highlighting module and related docs/tests.
- Autocompletion remains available via completion/autocomplete.sh.

## v1.0.2 - 2026-01-30
### Added
- completion/ modules for autocomplete and highlighting.
- Completion documentation and tests.
### Changed
- main.sh now sources completion modules.
- Test runners include completion test.
- STRUCTURE.md refreshed after adding completion assets.

## v1.0.1 - 2026-01-30
### Added
- Directory overview files duplicated into docs/ as <path>.md for centralized access.
### Changed
- docs/README.md updated to link to docs-based overview files.

## v1.0.0 - 2026-01-30
### Added
- Documentation system under docs/ with project summary, structure output, and per-directory overviews.
