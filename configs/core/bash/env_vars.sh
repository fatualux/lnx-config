#!/bin/bash

# Editor
export EDITOR=vim
export VISUAL=vim

# Python
export POETRY_VIRTUALENVS_IN_PROJECT=1
export PYTHONPATH=.

# X11
export DISPLAY=:0

# NVidia & PATH
export PATH="$HOME/.vscode-server/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/mnt/c/Users:$PATH"
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Certificates
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
