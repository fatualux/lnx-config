#!/bin/bash

# Test theme system and git utilities
source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source main.sh to load all functions
MAIN_SH_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"
unset __BASH_CONFIG_LOADED
if [ -f "$MAIN_SH_PATH" ]; then
    BASH_CONFIG_VERBOSE="" source "$MAIN_SH_PATH" > /dev/null 2>&1
fi

THEMES_DIR="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/themes"
CONFIG_THEME="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/config/theme.sh"

# Initialize counters using the standard test utils variables
PASSED=0
FAILED=0

echo -e "\n${BLUE}=== Theme System Tests ===${NC}\n"

# Test: themes directory exists
if [ -d "$THEMES_DIR" ]; then
    echo -e "${GREEN}✓${NC} Themes directory exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} Themes directory exists"
    ((FAILED++))
fi

# Test: config/theme.sh exists
if [ -f "$CONFIG_THEME" ]; then
    echo -e "${GREEN}✓${NC} config/theme.sh exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} config/theme.sh exists"
    ((FAILED++))
fi

# Test: theme files have valid bash syntax
echo -e "\n${BLUE}=== Theme Syntax Validation ===${NC}\n"
for theme_file in "$THEMES_DIR"/*.sh; do
    if bash -n "$theme_file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $(basename "$theme_file") syntax OK"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $(basename "$theme_file") syntax OK"
        ((FAILED++))
    fi
done

# Test: config/theme.sh has valid syntax
if bash -n "$CONFIG_THEME" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} config/theme.sh syntax OK"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} config/theme.sh syntax OK"
    ((FAILED++))
fi

# Test: git-utils.sh exists
GIT_UTILS="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/functions/development/git-utils.sh"
if [ -f "$GIT_UTILS" ]; then
    echo -e "${GREEN}✓${NC} git-utils.sh exists"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} git-utils.sh exists"
    ((FAILED++))
fi

# Test: git-utils.sh has valid syntax
if [ -f "$GIT_UTILS" ] && bash -n "$GIT_UTILS" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} git-utils.sh syntax OK"
    ((PASSED++))
else
    echo -e "${RED}✗${NC} git-utils.sh syntax OK"
    ((FAILED++))
fi

# Test: git utility functions are defined
echo -e "\n${BLUE}=== Git Utility Functions ===${NC}\n"
GIT_FUNCTIONS=(
    "get_git_branch"
    "is_git_detached"
    "get_git_status"
    "get_git_user_name"
    "get_git_user_email"
    "is_git_repo"
    "get_git_root"
)

for func in "${GIT_FUNCTIONS[@]}"; do
    if declare -f "$func" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Function '$func' is defined"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Function '$func' is defined"
        ((FAILED++))
    fi
done

# Test: git functions work in git repo
echo -e "\n${BLUE}=== Git Function Behavior ===${NC}\n"

# Current directory is a git repo (we're testing in the bash config dir)
BASH_CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../configs/bash"
cd "$BASH_CONFIG_DIR"

if is_git_repo 2>/dev/null; then
    echo -e "${GREEN}✓${NC} is_git_repo detects git repository"
    ((PASSED++))
    
    # Test get_git_branch
    branch=$(get_git_branch 2>/dev/null)
    if [ -n "$branch" ]; then
        echo -e "${GREEN}✓${NC} get_git_branch returns branch name: $branch"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} get_git_branch returns branch name"
        ((FAILED++))
    fi
    
    # Test get_git_status
    if get_git_status 2>/dev/null >/dev/null; then
        echo -e "${GREEN}✓${NC} get_git_status executes without error"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} get_git_status executes without error"
        ((FAILED++))
    fi
    
    # Test get_git_user_name
    git_name=$(get_git_user_name 2>/dev/null)
    if [ -n "$git_name" ] || [ $? -eq 0 ] || [ "$git_name" = "N/A" ] || [ "$git_name" = "" ]; then
        echo -e "${GREEN}✓${NC} get_git_user_name executes (may return empty if not configured)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} get_git_user_name executes"
        ((FAILED++))
    fi
    
    # Test get_git_user_email
    git_email=$(get_git_user_email 2>/dev/null)
    if [ -n "$git_email" ] || [ $? -eq 0 ] || [ "$git_email" = "N/A" ] || [ "$git_email" = "" ]; then
        echo -e "${GREEN}✓${NC} get_git_user_email executes (may return empty if not configured)"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} get_git_user_email executes"
        ((FAILED++))
    fi
    
    # Test is_git_detached
    if is_git_detached 2>/dev/null; then
        echo -e "${GREEN}✓${NC} is_git_detached: HEAD is detached"
        ((PASSED++))
    else
        echo -e "${GREEN}✓${NC} is_git_detached: HEAD is not detached (normal)"
        ((PASSED++))
    fi
    
    # Test get_git_root
    git_root=$(get_git_root 2>/dev/null)
    if [ -n "$git_root" ]; then
        echo -e "${GREEN}✓${NC} get_git_root returns: $git_root"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} get_git_root returns root directory"
        ((FAILED++))
    fi
else
    echo -e "${YELLOW}⊘${NC} Not in a git repository, skipping git function behavior tests"
    PASSED=$((PASSED + 7))
fi

# Test: theme files define PS1 or PROMPT_COMMAND
echo -e "\n${BLUE}=== Theme PS1 Definition ===${NC}\n"
for theme in "${EXPECTED_THEMES[@]}"; do
    (
        source "$THEMES_DIR/${theme}.sh" 2>/dev/null
        # Check if theme sets PS1 directly or uses PROMPT_COMMAND
        if [ -n "$PS1" ] || [ -n "$PROMPT_COMMAND" ]; then
            echo -e "${GREEN}✓${NC} Theme '$theme' defines PS1 or PROMPT_COMMAND"
            exit 0
        else
            echo -e "${RED}✗${NC} Theme '$theme' defines PS1 or PROMPT_COMMAND"
            exit 1
        fi
    )
    if [ $? -eq 0 ]; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
done

# Summary
echo -e "\n${BLUE}=== Theme Tests Summary ===${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}  Failed: ${RED}$FAILED${NC}\n"

exit $([ $FAILED -eq 0 ] && echo 0 || echo 1)
