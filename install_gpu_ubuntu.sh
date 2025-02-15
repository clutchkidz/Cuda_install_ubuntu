#!/bin/bash

echo "🚀 Starting NVIDIA GPU & CUDA Installation Script for Ubuntu 24.04 🚀"

# Ensure system is up to date
echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "🔧 Installing build tools, Python, and Git..."
sudo apt install -y git build-essential python3.12-venv python3-pip

# Auto-install recommended NVIDIA drivers
echo "🔍 Detecting and installing recommended NVIDIA drivers..."
sudo ubuntu-drivers autoinstall

# Add NVIDIA CUDA Repository
echo "🌐 Adding NVIDIA CUDA repository..."
curl -fSsL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/nvidia-drivers.gpg > /dev/null 2>&1

echo "deb [signed-by=/usr/share/keyrings/nvidia-drivers.gpg] https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/ /" | sudo tee /etc/apt/sources.list.d/nvidia-drivers.list

# Update package list
echo "🔄 Refreshing package list..."
sudo apt update

# Install NVIDIA drivers and CUDA toolkit
echo "🎯 Installing NVIDIA drivers and CUDA toolkit..."
sudo apt install -y nvidia-driver-560 cuda-drivers-560 libnvidia-compute-560 \
nvidia-compute-utils-560 nvidia-kernel-common-560 cuda-toolkit-12-8-config-common \
cuda-toolkit-12-config-common cuda-toolkit-config-common cuda-visual-tools-12-8 \
linux-modules-nvidia-560-open-6.11.0-14-generic linux-modules-nvidia-560-open-generic \
nvidia-driver-560-open nvidia-kernel-source-560-open

# Verify NVIDIA Installation
echo "🔍 Checking NVIDIA GPU detection..."
if ! nvidia-smi > /dev/null 2>&1; then
    echo "❌ NVIDIA GPU not detected! Please reboot and run 'nvidia-smi' manually."
    exit 1
fi
echo "✅ NVIDIA GPU detected!"

# Verify CUDA Installation
echo "🔍 Checking CUDA installation..."
if ! command -v nvcc &> /dev/null; then
    echo "❌ CUDA not found! Please check the installation or restart your system."
    exit 1
fi
echo "✅ CUDA installed! Version:"
nvcc --version

# Add CUDA to PATH if missing
if ! echo "$PATH" | grep -q "/usr/local/cuda/bin"; then
    echo "🔧 Adding CUDA to PATH..."
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    source ~/.bashrc
fi

# Test NVIDIA & CUDA setup
echo "🔬 Running CUDA device query test..."
cd /usr/local/cuda/samples/1_Utilities/deviceQuery || exit
sudo make > /dev/null 2>&1
./deviceQuery

# Test PyTorch CUDA compatibility
echo "🧠 Verifying PyTorch CUDA support..."
python3 -c "
import torch
print('PyTorch CUDA Available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('GPU:', torch.cuda.get_device_name(0))
"

# Test TensorFlow CUDA compatibility
echo "🤖 Verifying TensorFlow CUDA support..."
python3 -c "
import tensorflow as tf
print('TensorFlow CUDA Devices:', tf.config.list_physical_devices('GPU'))
"

echo "🎉 Installation complete! Reboot your system to finalize the setup."

