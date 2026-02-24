#!/bin/bash
set -e

NB_USER=${NB_USER:-jovyan}

COMFYUI_HOME="/home/$NB_USER/ComfyUI"
PERSISTENT_MODELS="$COMFYUI_HOME/models"
SCRATCH_BASE="/scratch"
SCRATCH_MODELS="$SCRATCH_BASE/comfyui_models"

echo "=== ComfyUI scratch initialization ==="

# Check if scratch exists
if [ -d "$SCRATCH_BASE" ]; then
    echo "Scratch storage detected at $SCRATCH_BASE"

    mkdir -p "$SCRATCH_MODELS"

    # Copy only if not already copied
    if [ ! -f "$SCRATCH_MODELS/.copy_complete" ]; then
        echo "Copying models to NVMe scratch..."

        rsync -a --info=progress2 \
            "$PERSISTENT_MODELS/" \
            "$SCRATCH_MODELS/"

        touch "$SCRATCH_MODELS/.copy_complete"
        echo "Model copy complete."
    else
        echo "Models already cached in scratch."
    fi

    # Replace models directory with symlink
    if [ -d "$PERSISTENT_MODELS" ] && [ ! -L "$PERSISTENT_MODELS" ]; then
        echo "Linking ComfyUI models → scratch"
        rm -rf "$PERSISTENT_MODELS"
        ln -s "$SCRATCH_MODELS" "$PERSISTENT_MODELS"
    fi

else
    echo "No scratch volume detected. Using persistent storage."
fi

chown -R $NB_USER:$NB_USER "$COMFYUI_HOME" || true