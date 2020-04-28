#!/bin/bash
docker build -t sim . && \
docker run --privileged -it --rm --gpus all \
  -p 40001:8081 \
  -e RESOLUTION=1920x1080 \
  --mount type=bind,source=/usr/local/MATLAB,target=/usr/local/MATLAB,readonly \
  --mount type=bind,source=/var/run/dbus/system_bus_socket,target=/var/run/dbus/system_bus_socket \
  --name sim sim
