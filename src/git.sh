#!/bin/bash

# Git configuration module

# Function to configure git
configure_git() {
    log_section "Configuring Git"
    
    # Set user name if provided
    if [[ -n "$user_name" ]]; then
        log_info "Setting git user name: $user_name"
        git config --global user.name "$user_name"
    fi
    
    # Set user email if provided
    if [[ -n "$user_email" ]]; then
        log_info "Setting git user email: $user_email"
        git config --global user.email "$user_email"
    fi
    
    # Set default branch name
    log_info "Setting default branch name to main"
    git config --global init.defaultBranch main
    
    # Set pull rebase behavior
    log_info "Setting pull.rebase to false"
    git config --global pull.rebase false
    
    # Set push default behavior
    log_info "Setting push.default to simple"
    git config --global push.default simple
    
    log_success "Git configuration completed"
}

# Function to initialize git repository
init_git_repo() {
    local repo_path="$1"
    
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path does not exist: $repo_path"
        return 1
    fi
    
    if [[ -d "$repo_path/.git" ]]; then
        log_info "Git repository already exists: $repo_path"
        return 0
    fi
    
    log_info "Initializing git repository: $repo_path"
    if (cd "$repo_path" && git init); then
        log_success "Git repository initialized: $repo_path"
    else
        log_error "Failed to initialize git repository: $repo_path"
        return 1
    fi
}

# Function to add remote
add_git_remote() {
    local repo_path="$1"
    local remote_name="$2"
    local remote_url="$3"
    
    if [[ ! -d "$repo_path/.git" ]]; then
        log_error "Not a git repository: $repo_path"
        return 1
    fi
    
    log_info "Adding remote $remote_name: $remote_url"
    if (cd "$repo_path" && git remote add "$remote_name" "$remote_url"); then
        log_success "Remote added: $remote_name"
    else
        log_error "Failed to add remote: $remote_name"
        return 1
    fi
}

# Function to create initial commit
create_initial_commit() {
    local repo_path="$1"
    local message="${2:-Initial commit}"
    
    if [[ ! -d "$repo_path/.git" ]]; then
        log_error "Not a git repository: $repo_path"
        return 1
    fi
    
    log_info "Creating initial commit in: $repo_path"
    if (cd "$repo_path" && git add . && git commit -m "$message"); then
        log_success "Initial commit created"
    else
        log_error "Failed to create initial commit"
        return 1
    fi
}
