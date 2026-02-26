#!/bin/bash

# Ensure NB_USER is set
if [ -z "$NB_USER" ]; then
    echo "NB_USER is not set."
    return 1
fi

# Run /opt/install_comfyui.sh as $NB_USER
sudo -u "$NB_USER" /opt/install_comfyui.sh