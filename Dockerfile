#FROM gitlab-registry.nrp-nautilus.io/nrp/scientific-images/python:tensorflow-cuda-v1.5.0
FROM quay.io/jupyter/pytorch-notebook:cuda12-latest


USER root

ENV COMFYUI_PATH=/home/$NB_USER/ComfyUI
ENV COMFYUI_TEMPLATE_DIR=/opt/comfyui-template
ENV PATH="$PATH:$COMFYUI_PATH"
ENV COMFYUI_SESSION_TIMEOUT=600
ENV UV_CACHE_DIR=/opt/conda/.uv-cache

RUN apt-get update && apt-get install -y git rsync && rm -rf /var/lib/apt/lists/*

ADD jupyter_comfyui_proxy /home/extensions/jupyter_comfyui_proxy
RUN pip install uv /home/extensions/jupyter_comfyui_proxy/.

# Preinstall ComfyUI into the image so startup avoids git clone + dependency install.
RUN mkdir -p "$UV_CACHE_DIR" \
    && git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_TEMPLATE_DIR" \
    && uv pip install -v --system -r "$COMFYUI_TEMPLATE_DIR/requirements.txt" \
    && uv pip install -v --system comfyui-manager \
    && chown -R ${NB_UID}:${NB_GID} "$COMFYUI_TEMPLATE_DIR" "$UV_CACHE_DIR"

# Configure Jupyter to run comfyui install script at startup
RUN mkdir -p /usr/local/bin/start-notebook.d

ADD docker/sourced_comfyui.sh /usr/local/bin/start-notebook.d/sourced_comfyui.sh
RUN chmod +x /usr/local/bin/start-notebook.d/sourced_comfyui.sh

ADD docker/comfyui_manager_config.ini /opt/comfyui-manager-config.ini

ADD docker/install_comfyui.sh /opt/install_comfyui.sh
RUN chmod +x /opt/install_comfyui.sh

ADD docker/symlink_shared_models.sh /usr/local/bin/start-notebook.d/symlink_shared_models.sh
RUN chmod +x /usr/local/bin/start-notebook.d/symlink_shared_models.sh

USER $NB_USER