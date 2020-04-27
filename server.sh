#!/bin/bash
docker build -t sim . && \
# docker run --device=/dev/tty0:rw -it --rm --gpus all \
docker run --privileged -it --rm --gpus all \
  -p 8081:8081 \
  -e RESOLUTION=1080x720 \
  -e VNCPASS=pass \
  --mount type=bind,source=/var/run/dbus/system_bus_socket,target=/var/run/dbus/system_bus_socket \
  --name sim sim
  # -v $HOME/hoge:/hoge:ro \
