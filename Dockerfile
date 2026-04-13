# Use NVIDIA CUDA base image optimized for Python 3.10 and Ubuntu 22.04
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    git-lfs \
    wget \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone the main ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# 3. Install PyTorch with CUDA 12.4 support (essential for FLUX models)
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# 4. Install ComfyUI core dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# 5. Pre-install ComfyUI-Manager (This gives you the "Download on Pod" functionality)
WORKDIR /app/custom_nodes
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git comfyui-manager
RUN pip3 install --no-cache-dir -r comfyui-manager/requirements.txt

# 6. Create necessary model directories (ensures they exist for volume mounting)
WORKDIR /app
RUN mkdir -p models/checkpoints models/unet models/vae models/clip models/loras output input

# 7. Expose the default ComfyUI port
EXPOSE 8188

# 8. Start Script: Launches ComfyUI and listens on all interfaces
# The --listen 0.0.0.0 flag is CRITICAL for cloud pods (RunPod/Vast)
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
