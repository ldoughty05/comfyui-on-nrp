#!/bin/bash
# 00_install_comfyui.sh
set -ex

export NB_USER=${NB_USER:-"jovyan"}

LOGFILE="/home/$NB_USER/comfyui_install_script.log"
exec > >(tee -a "$LOGFILE") 2>&1

COMFYUI_HOME="/home/$NB_USER/ComfyUI"


if [ -d "$COMFYUI_HOME" ]; then
    echo "ComfyUI already installed at $COMFYUI_HOME. Skipping installation."
else
    echo "Installing ComfyUI to $COMFYUI_HOME..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_HOME"
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$COMFYUI_HOME/custom_nodes/comfyui-manager"
    chown -R $NB_USER:$NB_USER "$COMFYUI_HOME"
fi

# Find pip or pip3 location
if command -v pip &>/dev/null; then
    PIP_CMD=$(command -v pip)
elif command -v pip3 &>/dev/null; then
    PIP_CMD=$(command -v pip3)
elif [ -f "/opt/conda/bin/pip" ]; then
    PIP_CMD="/opt/conda/bin/pip"
elif [ -f "/usr/local/bin/pip3" ]; then
    PIP_CMD="/usr/local/bin/pip3"
else
    echo "pip or pip3 not found. Please install pip."
    exit 1
fi

export PATH="$(dirname "$PIP_CMD"):$PATH"
echo "Detected pip command at: $PIP_CMD"

# Find uv location
if command -v uv &>/dev/null; then
    UV_CMD=$(command -v uv)
elif [ -f "/opt/conda/bin/uv" ]; then
    UV_CMD="/opt/conda/bin/uv"
elif [ -f "/usr/local/bin/uv" ]; then
    UV_CMD="/usr/local/bin/uv"
else
    echo "uv not found. Installing uv..."
    "$PIP_CMD" install uv
    if command -v uv &>/dev/null; then
        UV_CMD=$(command -v uv)
    elif [ -f "/opt/conda/bin/uv" ]; then
        UV_CMD="/opt/conda/bin/uv"
    elif [ -f "/usr/local/bin/uv" ]; then
        UV_CMD="/usr/local/bin/uv"
    else
        echo "uv installation failed."
        exit 1
    fi
fi

export PATH="$(dirname "$UV_CMD"):$PATH"
echo "Detected uv command at: $UV_CMD"
UV_CACHE_DIR="/tmp"
echo "UV_CACHE_DIR at: $UV_CACHE_DIR"

# Install packages again to ensure all are installed correctly
"$UV_CMD" pip install --system -r "$COMFYUI_HOME/requirements.txt"
