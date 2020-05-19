FROM 921287185969.dkr.ecr.us-east-1.amazonaws.com/robo-ninja-warrior:qeasim

# Make all NVIDIA GPUS visible, but I want to manually install drivers
ARG NVIDIA_VISIBLE_DEVICES=all
# Supress interactive menu while installing keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y nvidia-driver-435 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
