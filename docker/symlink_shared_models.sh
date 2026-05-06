# symlink_shared_models.sh
#!/bin/bash
SHARED=/mnt/shared-models
MODELS=/home/jovyan/ComfyUI/models

if [ -d "$SHARED" ] && [ "$(ls -A $SHARED)" ]; then
    echo "Symlinking shared models..."
    for dir in "$SHARED"/*/; do
        name=$(basename "$dir")
        target="$MODELS/$name"
        if [ ! -e "$target" ]; then
            ln -s "$dir" "$target"
            echo "Linked $name"
        else
            echo "Skipping $name (already exists)"
        fi
    done
fi