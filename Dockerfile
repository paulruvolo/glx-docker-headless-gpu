FROM ubuntu:18.04

# Make all NVIDIA GPUS visible, but I want to manually install drivers
ARG NVIDIA_VISIBLE_DEVICES=all
# Supress interactive menu while installing keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

# Error constructing proxy for org.gnome.Terminal:/org/gnome/Terminal/Factory0: Failed to execute child process dbus-launch (No such file or directory)
# fix by setting LANG https://askubuntu.com/questions/608330/problem-with-gnome-terminal-on-gnome-3-12-2
# to install locales https://stackoverflow.com/questions/39760663/docker-ubuntu-bin-sh-1-locale-gen-not-found
RUN apt-get clean && \
    apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# (1) Install Xorg and NVIDIA driver inside the container
# Almost same procesure as nvidia/driver https://gitlab.com/nvidia/driver/blob/master/ubuntu16.04/Dockerfile

# (1-1) Install prerequisites
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        wget \
        vim \
        zip \
        unzip \
        git \
        python \
        kmod \
        libc6:i386 \
        pkg-config \
        nvidia-driver-435 \
        libelf-dev && \
    rm -rf /var/lib/apt/lists/*

# (1-2) Install xorg server and xinit BEFORE INSTALLING NVIDIA DRIVER.
# After this installation, command Xorg and xinit can be used in the container
# if you need full ubuntu desktop environment, the line below should be added.
        # ubuntu-desktop \
RUN apt-get update && apt-get install -y \
        xinit && \
    rm -rf /var/lib/apt/lists/*

# (1-3) Install NVIDIA drivers, including X graphic drivers
# Same command as nvidia/driver, except --x-{prefix,module-path,library-path,sysconfig-path} are omitted in order to make use default path and enable X drivers.
# Driver version must be equal to host's driver
# Install the userspace components and copy the kernel module sources.

# (2) Configurate Xorg
# (2-1) Install some necessary softwares
#
# pkg-config: nvidia-xconfig requires this package
# mesa-utils: This package includes glxgears and glxinfo, which is useful for testing GLX drivers
# x11vnc: Make connection between x11 server and VNC client.
# x11-apps: xeyes can be used to make sure that X11 server is running.
#
# Note: x11vnc in ubuntu18.04 is useless beacuse of stack smashing bug. See below to manual compilation.
RUN apt-get update && apt-get install -y --no-install-recommends \
        mesa-utils \
        x11-apps && \
    rm -rf /var/lib/apt/lists/*

# solution for the `stack smashing detected` issue
# https://github.com/LibVNC/x11vnc/issues/61
RUN apt-get update && apt-get install -y --no-install-recommends \
        automake autoconf libssl-dev xorg-dev libvncserver-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/LibVNC/x11vnc.git && \
    cd x11vnc && \
    ./autogen.sh && \
    make && \
    cp src/x11vnc /usr/bin/x11vnc

# (2-2) Optional vulkan support
# vulkan-utils includes vulkan-smoketest, benchmark software of vulkan API
RUN apt-get update && apt-get install -y --no-install-recommends \
        libvulkan1 vulkan-utils && \
    rm -rf /var/lib/apt/lists/*

# for test
RUN apt-get update && apt-get install -y --no-install-recommends \
        firefox openbox && \
    rm -rf /var/lib/apt/lists/*

# sound driver and GTK library
# If you want to use sounds on docker, try `pulseaudio --start`
RUN apt-get update && apt-get install -y --no-install-recommends \
      alsa pulseaudio libgtk2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# novnc
# download websockify as well
RUN wget https://github.com/novnc/noVNC/archive/v1.1.0.zip && \
  unzip -q v1.1.0.zip && \
  rm -rf v1.1.0.zip && \
  git clone https://github.com/novnc/websockify /noVNC-1.1.0/utils/websockify

# Xorg segfault error
# dbus-core: error connecting to system bus: org.freedesktop.DBus.Error.FileNotFound (Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory)
# related? https://github.com/Microsoft/WSL/issues/2016
RUN apt-get update && apt-get install -y --no-install-recommends \
      dbus-x11 \
      libdbus-c++-1-0v5 && \
    rm -rf /var/lib/apt/lists/*

# (3) Run Xorg server + x11vnc + X applications
# see run.sh for details
COPY run.sh /run.sh
CMD ["bash", "/run.sh"]
