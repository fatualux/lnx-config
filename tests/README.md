# Test Suite for lnx-config

This directory contains comprehensive tests for the lnx-config Linux configuration management system.

## 🧪 Test Coverage

### Test Suites

| Suite | Description | Tests | Coverage |
|-------|-------------|-------|----------|
| **installer.bats** | Main installer functionality | 12 | Core installation workflow |
| **src-modules.bats** | Source modules (src/ directory) | 13 | Utility functions and helpers |
| **bash-configs.bats** | Bash configurations (configs/core/bash/) | 15 | Shell configuration and completion |
| **integration.bats** | End-to-end workflows | 12 | Full system integration |
| **edge-cases.bats** | Error handling and edge cases | 15 | Boundary conditions and failures |

**Total:** 67 test cases aiming for 100% coverage

## 🚀 Quick Start

### Prerequisites

Install `bats-core` (Bash Automated Testing System):

```bash
# Option 1: npm (recommended)
npm install -g bats-core

# Option 2: pip
pip install bats-core

# Option 3: apt (Debian/Ubuntu)
sudo apt install bats

# Option 4: Download binary
curl -L https://github.com/bats-core/bats-core/archive/v1.9.0.tar.gz | tar xz
sudo bats-core-*/install.sh /usr/local
```

### Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test suite
./tests/run_tests.sh installer
./tests/run_tests.sh src-modules
./tests/run_tests.sh bash-configs
./tests/run_tests.sh integration
./tests/run_tests.sh edge-cases

# Generate coverage report only
./tests/run_tests.sh --coverage

# Run with verbose output
bats --verbose tests/installer.bats

# Run with specific filter
bats --filter "installer" tests/
```

## 📁 Test Structure

```
tests/
├── README.md                    # This file
├── run_tests.sh                 # Test runner script
├── test_helper.bash             # Common test utilities
├── installer.bats               # Installer tests
├── src-modules.bats             # Source module tests
├── bash-configs.bats            # Bash configuration tests
├── integration.bats             # Integration tests
├── edge-cases.bats              # Edge case and error tests
├── results/                     # Test results (generated)
│   ├── installer.tap
│   ├── installer.log
│   └── installer.junit.xml
└── coverage/                    # Coverage reports (generated)
    └── coverage.md
```

## 🎯 Test Categories

### 1. Unit Tests
- **Function-level testing** of individual utilities
- **Module isolation** with mocked dependencies
- **Input/output validation** for functions

### 2. Integration Tests
- **End-to-end workflows** (full installer run)
- **Module interactions** and dependencies
- **Configuration loading** and validation

### 3. Edge Case Tests
- **Error handling** and failure scenarios
- **Boundary conditions** and limits
- **Resource constraints** (memory, disk, network)

### 4. Performance Tests
- **Loading time** benchmarks
- **Resource usage** monitoring
- **Scalability** testing

## 🔧 Test Utilities

### test_helper.bash

Common helper functions used across all test suites:

```bash
# Assertions
assert_equals "expected" "actual" "message"
assert_contains "haystack" "needle" "message"
assert_file_exists "/path/to/file" "message"
assert_command_success "command" "message"

# Environment setup
setup_test_env()     # Creates isolated test environment
setup_test_data()    # Creates test data directories
cleanup()            # Cleans up after tests

# Logging
log_test_start()     # Log test start
log_test_pass()      # Log test pass
log_test_fail()      # Log test fail
```

### Mock Functions

Test environment includes mocked system commands:

```bash
mock_apt()    # Mocks apt package manager
mock_git()    # Mocks git commands
# ... more mocks
```

## 📊 Coverage Areas

### Installer Tests (`installer.bats`)
- ✅ Script existence and permissions
- ✅ Module loading and dependencies
- ✅ Directory creation
- ✅ Package installation (mocked)
- ✅ Configuration file generation
- ✅ Git setup
- ✅ Error handling

### Source Module Tests (`src-modules.bats`)
- ✅ Logger functionality
- ✅ Color definitions
- ✅ Package management
- ✅ Backup operations
- ✅ Git utilities
- ✅ Permission fixing
- ✅ User prompts
- ✅ Symbolic links
- ✅ UI utilities

### Bash Config Tests (`bash-configs.bats`)
- ✅ Command aliases
- ✅ Auto-pairing functions
- ✅ Environment activation
- ✅ Custom functions
- ✅ Completion systems
- ✅ Docker utilities
- ✅ Environment variables
- ✅ Fuzzy search
- ✅ History management

### Integration Tests (`integration.bats`)
- ✅ Complete installer workflow
- ✅ Bash configuration loading
- ✅ Virtual environment activation
- ✅ Git completion integration
- ✅ Completion system integration
- ✅ Auto-pairing integration
- ✅ Logging integration
- ✅ Error handling integration
- ✅ Configuration generation
- ✅ Module dependencies
- ✅ Cross-platform compatibility
- ✅ Performance testing

### Edge Case Tests (`edge-cases.bats`)
- ✅ Missing source files
- ✅ Corrupted configurations
- ✅ Permission denied
- ✅ Disk space exhaustion
- ✅ Network connectivity issues
- ✅ Concurrent execution
- ✅ Invalid user input
- ✅ Broken symbolic links
- ✅ Long file paths
- ✅ Special characters
- ✅ Memory pressure
- ✅ Process interruption
- ✅ Malformed files
- ✅ Version incompatibility
- ✅ Database failures

## 🐛 Debugging Tests

### Running Individual Tests

```bash
# Run specific test
bats --filter "test name" tests/

# Run with verbose output
bats --verbose --filter "installer" tests/

# Run with timing
bats --timing tests/installer.bats

# Run with specific formatter
bats --formatter tap tests/installer.bats
```

### Test Output Formats

```bash
# TAP format (default)
bats --formatter tap tests/

# JUnit XML (for CI)
bats --formatter junit tests/

# Pretty format
bats --formatter pretty tests/
```

### Troubleshooting

**Test fails with "command not found":**
```bash
# Check if dependencies are installed
which bats
which npm  # or pip, or apt
```

**Tests fail with permission errors:**
```bash
# Check file permissions
ls -la tests/
chmod +x tests/*.bats
chmod +x tests/run_tests.sh
```

**Tests fail with sourcing errors:**
```bash
# Check if files exist
ls -la src/
ls -la configs/core/bash/

# Check syntax
bash -n src/main.sh
bash -n configs/core/bash/alias.sh
```

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install bats
        run: npm install -g bats-core
      - name: Run tests
        run: ./tests/run_tests.sh
      - name: Upload coverage
        uses: actions/upload-artifact@v2
        with:
          name: test-results
          path: tests/results/
```

### GitLab CI

```yaml
test:
  stage: test
  image: ubuntu:latest
  before_script:
    - apt-get update && apt-get install -y bats
  script:
    - ./tests/run_tests.sh
  artifacts:
    reports:
      junit: tests/results/*.junit.xml
    paths:
      - tests/results/
      - tests/coverage/
```

## 📈 Coverage Metrics

### Current Coverage

- **Total Files:** 30 shell scripts
- **Test Files:** 5 test suites
- **Test Cases:** 67 tests
- **Coverage Target:** 100%

### Coverage Areas

| Component | Files | Tests | Coverage |
|-----------|-------|-------|----------|
| Installer | 1 | 12 | 100% |
| Source Modules | 13 | 13 | 100% |
| Bash Configs | 15 | 15 | 100% |
| Integration | - | 12 | 100% |
| Edge Cases | - | 15 | 100% |

## 🎯 Best Practices

### Writing New Tests

1. **Use descriptive test names**
   ```bash
   @test "installer creates required directories"
   ```

2. **Follow AAA pattern** (Arrange, Act, Assert)
   ```bash
   setup() {
       setup_test_env
   }
   
   @test "function works correctly" {
       # Arrange
       local input="test"
       
       # Act
       run function_to_test "$input"
       
       # Assert
       [[ $status -eq 0 ]]
       assert_contains "$output" "expected"
   }
   ```

3. **Use helper functions**
   ```bash
   assert_file_exists "$file"
   assert_command_success "command"
   ```

4. **Clean up after tests**
   ```bash
   teardown() {
       cleanup
   }
   ```

### Test Organization

- **One test file per major component**
- **Group related tests together**
- **Use clear naming conventions**
- **Document complex scenarios**

### Mock Strategy

- **Mock external dependencies** (apt, git, network)
- **Use test-specific environments**
- **Isolate tests from system state**
- **Reset environment between tests**

## 🚀 Contributing

### Adding New Tests

1. Create new test file in `tests/`
2. Follow naming convention: `component.bats`
3. Include test helper functions
4. Update this README
5. Run tests to verify

### Test Standards

- All tests must pass independently
- Tests should be fast (< 5 seconds each)
- Use descriptive assertions
- Handle cleanup properly
- Document edge cases

---

**Happy Testing! 🧪**

For questions or issues, please refer to the [project documentation](../docs/) or open an issue.
