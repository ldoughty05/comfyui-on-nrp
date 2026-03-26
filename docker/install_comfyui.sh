#!/bin/bash
# install_comfyui.sh
set -ex

export NB_USER=${NB_USER:-"jovyan"}
export COMFYUI_TEMPLATE_DIR=${COMFYUI_TEMPLATE_DIR:-"/opt/comfyui-template"}

LOGFILE="/home/$NB_USER/comfyui_install_script.log"
exec > >(tee -a "$LOGFILE") 2>&1

COMFYUI_HOME="/home/$NB_USER/ComfyUI"

if [ ! -d "$COMFYUI_TEMPLATE_DIR" ]; then
    echo "ComfyUI template directory not found at $COMFYUI_TEMPLATE_DIR"
    exit 1
fi

echo "ComfyUI template directory: $COMFYUI_TEMPLATE_DIR"
echo "ComfyUI home directory: $COMFYUI_HOME"
echo "Resolved UV_CACHE_DIR: ${UV_CACHE_DIR:-"(not set)"}"
if [ -n "${UV_LINK_MODE:-}" ]; then
    echo "UV_LINK_MODE: $UV_LINK_MODE"
else
    echo "UV_LINK_MODE is not set"
fi

if [ -d "$COMFYUI_HOME" ]; then
    echo "ComfyUI already present at $COMFYUI_HOME. Skipping bootstrap copy."
else
    echo "Bootstrapping ComfyUI from image template..."
    mkdir -p "$COMFYUI_HOME"
    rsync -a --delete "$COMFYUI_TEMPLATE_DIR/" "$COMFYUI_HOME/"
    echo "ComfyUI bootstrap complete."
fi
