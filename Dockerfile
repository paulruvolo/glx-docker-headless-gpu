FROM osrf/ros:melodic-desktop-full-bionic
MAINTAINER Paul Ruvolo Paul.Ruvolo@olin.edu

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


RUN apt-get update -y && \
    apt-get install -y lsb-release gnupg2 apt-utils python-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -y && \
    apt-get install -y ros-melodic-rosbridge-suite \
    ros-melodic-geographic-msgs && \
    pip install tornado pymongo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
        lubuntu-desktop \
        terminator \
        libelf-dev && \
    rm -rf /var/lib/apt/lists/*

	# (1-3) Install NVIDIA drivers, including X graphic drivers
# Same command as nvidia/driver, except --x-{prefix,module-path,library-path,sysconfig-path} are omitted in order to make use default path and enable X drivers.
# Driver version must be equal to host's driver
# Install the userspace components and copy the kernel module sources.
ENV DRIVER_VERSION=418.87.00
ENV DRIVER_VERSION_PATH=418.87
RUN cd /tmp && \
    curl -fSsl -O https://us.download.nvidia.com/tesla/$DRIVER_VERSION_PATH/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run && \
    sh NVIDIA-Linux-x86_64-$DRIVER_VERSION.run -x && \
    cd NVIDIA-Linux-x86_64-$DRIVER_VERSION && \
    ./nvidia-installer --silent \
                       --no-kernel-module \
                       --install-compat32-libs \
                       --no-nouveau-check \
                       --no-nvidia-modprobe \
                       --no-rpms \
                       --no-backup \
                       --no-check-for-alternate-installs && \
    mkdir -p /usr/src/nvidia-$DRIVER_VERSION && \
    mv LICENSE mkprecompiled kernel /usr/src/nvidia-$DRIVER_VERSION && \
    sed '9,${/^\(kernel\|LICENSE\)/!d}' .manifest > /usr/src/nvidia-$DRIVER_VERSION/.manifest
                       # this option cannot be used on newer driver
                       # --no-glvnd-egl-client \
                       # --no-glvnd-glx-client \

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

# sound driver and GTK library
# If you want to use sounds on docker, try `pulseaudio --start`
RUN apt-get update && apt-get install -y --no-install-recommends \
      alsa pulseaudio libgtk2.0-0 lxde && \
    rm -rf /var/lib/apt/lists/*

# novnc
# download websockify as well
RUN wget https://github.com/novnc/noVNC/archive/v1.1.0.zip && \
  unzip -q v1.1.0.zip && \
  rm -rf v1.1.0.zip && \
  git clone https://github.com/novnc/websockify /noVNC-1.1.0/utils/websockify

# Xorg segfault error
# TODO: investigate this.  We are mapping the dbus system socket to get around an error that we encountered (maybe this fix is no longer needed?).
# dbus-core: error connecting to system bus: org.freedesktop.DBus.Error.FileNotFound (Failed to connect to socket /var/run/dbus/system_bus_socket: No such file or directory)
# related? https://github.com/Microsoft/WSL/issues/2016
RUN apt-get update && apt-get install -y --no-install-recommends \
      dbus-x11 \
      htop \
      libdbus-c++-1-0v5 && \
    rm -rf /var/lib/apt/lists/*

# Setup catkin workspace and ROS environment.
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
                  mkdir -p ~/catkin_ws/src && \
                  cd ~/catkin_ws/src && \
                  git clone -b qea https://github.com/comprobo18/comprobo18.git && \
                  git clone https://github.com/qeacourse/vrx.git && \
                  cd .. && \
                  catkin_make && \
                  echo 'source ~/catkin_ws/devel/setup.bash' >> ~/.bashrc"

ENV GAZEBO_MODEL_PATH=/root/.gazebo/models
# TODO: make a proper folder for meshes
RUN /bin/bash -c "mkdir -p ~/.gazebo/models; cp -r ~/catkin_ws/src/comprobo18/neato_gazebo/model/* ~/.gazebo/models; cp ~/catkin_ws/src/vrx/usv_gazebo_plugins/meshes/*.stl ~/.gazebo/models/bod/meshes"
RUN /bin/bash -c "mkdir -p ~/.gazebo/models/mobile_base && \
                  mkdir -p ~/.gazebo/models/mobile_base_with_camera && \
                  source ~/catkin_ws/devel/setup.bash && \
                  cp ~/catkin_ws/src/comprobo18/neato_robot/neato_description/sdf/neato.sdf ~/.gazebo/models/mobile_base/model.sdf && \
                  cp ~/catkin_ws/src/comprobo18/neato_robot/neato_description/sdf/neato_with_camera.sdf ~/.gazebo/models/mobile_base_with_camera/model.sdf && \
                  cp ~/catkin_ws/src/comprobo18/neato_robot/neato_description/model.config ~/.gazebo/models/mobile_base && \
                  cp ~/catkin_ws/src/comprobo18/neato_robot/neato_description/model_with_camera.config ~/.gazebo/models/mobile_base_with_camera/model.config && \
                  cp -r ~/catkin_ws/src/comprobo18/neato_robot/neato_description/meshes ~/.gazebo/models/mobile_base"

# Defeat screen locking and power management
RUN mv /etc/xdg/autostart/light-locker.desktop /etc/xdg/autostart/light-locker.desktop_bak
RUN mv /etc/xdg/autostart/xfce4-power-manager.desktop /etc/xdg/autostart/xfce4-power-manager.desktop_bak
COPY terminator.desktop /etc/xdg/autostart/

ARG SOURCEFORGE=https://sourceforge.net/projects
ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.6.3

RUN cd /tmp && \
    curl -fsSL -O ${SOURCEFORGE}/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb

# fix some other errors that tend to pop up and start a terminal at launch time
RUN rm /etc/xdg/autostart/lxpolkit.desktop && \
    rm /etc/xdg/autostart/update-notifier.desktop && \
    mv /usr/bin/lxpolkit /usr/bin/lxpolkit.ORIG

RUN /bin/bash -c "mkdir -p /root/Desktop"

COPY self.pem /root/self.pem
COPY launch_comgame /root/
COPY launch_boats /root/
COPY launch_boats_realistic /root/
COPY launch /root/
COPY matlab /root/

RUN /bin/bash -c "cd /tmp && \
                  git clone https://github.com/qeacourse/RoboNinjaWarrior && \
                  cp -r /tmp/RoboNinjaWarrior/Sample_code ~ && \
                  cp -r ~/catkin_ws/src/vrx/usv_gazebo_plugins/matlab_examples ~/matlab_boats && \
                  cp ~/catkin_ws/src/comprobo18/com_workshop/matlab_examples/*.m ~/matlab_boats && \
		  rm -rf /tmp/RoboNinjaWarrior"

RUN echo "echo \"type the command \\\"launch neato_world\\\" to launch the simulator\"" >> /root/.bashrc
RUN echo "echo \"for example, the command \\\"launch bod_volcano\\\" will load the world for the Bridge of Doom\"" >> /root/.bashrc

# Mostly just preserved for posterity (could remove)
COPY index.html /noVNC-1.1.0/index.html

ENV PATH /root:${PATH}:/usr/local/MATLAB/R2020a/bin

# (3) Run Xorg server + x11vnc + X applications
# see run.sh for details
COPY run.sh /run.sh
CMD ["bash", "/run.sh"]
