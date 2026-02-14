#!/bin/bash

# Source bash configuration from lnx-config installation
if [ -f ~/.lnx-config/configs/bash/main.sh ]; then
    # Unset the loaded flag to force reload in new shells
    unset __BASH_CONFIG_LOADED
    source ~/.lnx-config/configs/bash/main.sh
else
    echo "Warning: lnx-config bash configuration not found at ~/.lnx-config/configs/bash/main.sh"
fi
