# Test Suite for Linux Configuration Auto-Installer

This directory contains automated tests for the Linux Configuration Auto-Installer project using [Bats (Bash Automated Testing System)](https://github.com/bats-core/bats-core).

## Test Structure

### Test Files

- **`installer.test.bats`** - Tests core installer functionality
  - Backup creation and file operations
  - Configuration file generation (.bashrc, .vimrc)
  - Main workflow execution

- **`theme.test.bats`** - Tests bash theme and prompt functionality
  - Color variable definitions
  - IP address caching
  - Git integration functions
  - Prompt generation

- **`logger.test.bats`** - Tests logging system
  - Color variable definitions
  - Log level functions (info, success, warn, error)
  - Section headers
  - Message formatting

- **`integration.test.bats`** - End-to-end integration tests
  - Complete installer workflow
  - Backup and restoration scenarios
  - Error handling and edge cases

- **`test_helper.bash`** - Common test utilities and setup functions

## Running Tests

### Prerequisites

Install Bats (Bash Automated Testing System):

```bash
# On Ubuntu/Debian
sudo apt-get install bats

# On macOS with Homebrew
brew install bats-core

# Or install from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

### Running All Tests

```bash
# Run all tests
bats tests/

# Run with verbose output
bats -t tests/

# Run specific test file
bats tests/installer.test.bats

# Run with filter
bats -f "backup" tests/
```

### Running Individual Tests

```bash
# Run specific test
bats -f "creates backup directory" tests/

# Run with line numbers for debugging
bats --print-output-on-failure tests/
```

## Test Coverage

### Current Coverage

- ✅ **Backup functionality** - File backup and restoration
- ✅ **Configuration installation** - .bashrc and .vimrc creation
- ✅ **Theme system** - Git status display and prompt customization
- ✅ **Logging system** - Colored output and error handling
- ✅ **Integration workflows** - End-to-end installer execution

### Areas for Future Testing

- 🔄 **Cross-distribution compatibility** - Test on different Linux distributions
- 🔄 **Permission handling** - Test with various file permissions
- 🔄 **Network scenarios** - Test IP address resolution in different network conditions
- 🔄 **Git repository states** - Test with various git repository configurations

## Test Environment

The tests use a temporary directory structure to avoid affecting your actual configuration:

- `TEST_TEMP_DIR` - Temporary directory for each test run
- `HOME` - Mocked home directory within test temp dir
- `BACKUP_DIR` - Mocked backup directory
- `SCRIPT_DIR` - Points to the project root

## Safety Features

- Tests are skipped when running as root in `/root` directory for safety
- Temporary files are automatically cleaned up after each test
- Mock functions prevent actual system modifications during testing

## Contributing

When adding new tests:

1. Use descriptive test names that explain what is being tested
2. Follow the existing pattern of `setup()` and `teardown()` functions
3. Use helper functions from `test_helper.bash` when possible
4. Test both success and failure scenarios
5. Add documentation for new test files in this README

## Debugging Failed Tests

To debug failing tests:

```bash
# Run with verbose output
bats -t tests/

# Run with specific test and see output
bats -f "test name" tests/

# Run with shell tracing
bats --trace tests/

# Keep temporary files for inspection
export BATS_TMPDIR=/tmp/bats-debug
bats tests/
```
