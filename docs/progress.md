# Progress on NRP hosted ComfyUI intsance - Spring 2026

The past few months have been spent improving the user experience of ComfyUI hosted on NRP.  
The primary issues we sought to address were
long wait times to be assigned a pod,
long image generation times, especially for large models,
environment reproducibility for a classroom setting,
and ease of installing custom nodes

## Pod Load Times
The pod imaging workload has been streamlined by pre-installing the docker image and using a uv-cache.
The longest cause for delay in being assigned a pod is waiting for resources on NRP to become available. Unfortunately, this is out of our control. For people who use ComfyUI at regular times, this load time can be practically eliminated by using a Kubernetes cron job to request the pod ahead of time.

## Image Generation Time
At the start of this project, for large models especially, image generation times took up to an hour to finish. We discovered that the majority of that time was spent loading the model onto the GPUs. The most significant improvement was specifying that pods mount GPUs that are in the same geographic region as the user minimizing network latency. Other improvements include using faster GPUs, however this comes with the tradeoff of increased pod load times.

Lots of time went into trying different configurations for model storage volumes to try to maximize the effiency of I/O operations to speed up the time to load large models into GPU memory. There are three different storage volume types: Block, CephFS, and Linstor. CephFS yielded the worst results as it is optimized for parallel streams of read/write operations, however for this application it introduced too much overhead and latency. Linstor promises the fastest and smallest latency block storage, however it faces challenges when it comes to environment reproducibility as it only offers a ReadWriteOne mode. Block is easy to use, versitile, has low latency, and is ultimately what we decided on for this application.

## Reproduceable Environments
This development time was focused on improving the user experience for the case of using ComfyUI for a classroom setting. One of the most important project goals was to make ComfyUI "plug and play" with all of the useful models and nodes already loaded. The environment for each student should be identical and based on a "master image" created by the professor. With this, we hope to minimize the risk of unexpected behavior and technical issues getting in the way of learning. 

The first approach we took was to create a single *shared-models* directory which each student could mount to their pod so they all have access to a shared set of models without having to do any installations. 

Future work involves expanding on that success by making a student's entire pod a clone of the environment created by the professor. This will include the ComfyUI repo, models, and custom nodes. This can ensure the students are provided the resources they need to do good work, complete assignments, and not run into any instances of "it doesn't work on my machine".

## Easy Install Custom Nodes
We configured ComfyUI on NRP in an improved way that brings ComfyUI's full suite of features, most notably the ComfyUI Manager. The manager allows users to browse and one-click-install from a large, curated list of custom nodes. Examples of custom nodes include background removal nodes and various filters and functions.