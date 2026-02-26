#FROM gitlab-registry.nrp-nautilus.io/nrp/scientific-images/python:tensorflow-cuda-v1.5.0
FROM quay.io/jupyter/pytorch-notebook:cuda12-latest


USER root

ENV COMFYUI_PATH=/home/$NB_USER/ComfyUI
ENV PATH="$PATH:$COMFYUI_PATH"
ENV COMFYUI_SESSION_TIMEOUT=600
ENV UV_CACHE_DIR="$COMFYUI_PATH"

RUN apt-get update && apt-get install -y rsync && rm -rf /var/lib/apt/lists/*

ADD jupyter_comfyui_proxy /home/extensions/jupyter_comfyui_proxy
RUN pip install uv /home/extensions/jupyter_comfyui_proxy/.

# Configure Jupyter to run comfyui install script at startup
RUN mkdir -p /usr/local/bin/start-notebook.d

ADD docker/sourced_comfyui.sh /usr/local/bin/start-notebook.d/sourced_comfyui.sh
RUN chmod +x /usr/local/bin/start-notebook.d/sourced_comfyui.sh

ADD docker/install_comfyui.sh /opt/install_comfyui.sh
RUN chmod +x /opt/install_comfyui.sh

USER $NB_USER
