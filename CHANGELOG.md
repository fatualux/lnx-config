# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Fixed installer hanging at "Starting NixOS configuration rebuild..." by correcting non-existent spinner function calls
- Changed `safe_spinner_start` to `spinner_start` in nixos.sh
- Changed `safe_spinner_stop` to `spinner_stop` in nixos.sh
