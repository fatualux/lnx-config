# core/ Overview

## Purpose
Shared utilities that support logging, spinners, and ANSI color output.

## Contents
- colors.sh: ANSI color definitions for consistent terminal styling.
- logger.sh: Logging helpers for success, error, and info messages.
- spinner.sh: Terminal spinner utilities for long-running operations.
- OVERVIEW.md: This file.

## Usage Notes
- logger.sh and spinner.sh are guarded to prevent double sourcing.
- Functions here are used across scripts and integrations.
