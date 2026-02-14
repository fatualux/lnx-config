# tests/ Overview

## Purpose
Project-wide test suite for validating bash configuration, functions, integrations, and utility scripts.

## Contents
- run_tests_with_spinners.sh: Runs all test suites with spinner output.
- test_aliases.sh: Tests alias definitions and loaders.
- test_autocomplete.sh: Tests the smart completion module.
- test_readline.sh: Tests readline completion settings.
- test_docker.sh: Tests docker helpers.
- test_filesystem.sh: Tests filesystem helpers.
- test_integration.sh: Integration tests across modules.
- test_make_dir_tree.sh: Tests the directory tree generator.
- test_modules.sh: Tests module loading and sourcing.
- test_music.sh: Tests music helpers.
- test_themes.sh: Tests theme logic.
- test_utils.sh: Test utilities and assertions.
- logs/: Test output logs.

## Usage Notes
- Run the full suite from the project root with run_all_tests.sh.
- Logs are stored in tests/logs.
