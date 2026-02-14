# config/ Overview

## Purpose
Core shell configuration such as environment variables, history settings, and theme selection.

## Contents
- env_vars.sh: Environment variable exports and defaults.
- hist-token.sh: History search bindings based on current input.
- history.sh: History behavior and persistence settings.
- theme.sh: Theme selection and prompt configuration logic.
- OVERVIEW.md: This file.

## Usage Notes
- Files are sourced in bulk by main.sh.
- Theme selection relies on BASH_THEME before sourcing.
- History search binds Up/Down (and common alternatives) to search by current line prefix.
