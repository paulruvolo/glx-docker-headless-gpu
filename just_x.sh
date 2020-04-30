#!/bin/bash
docker run --privileged --rm --gpus all \
  -e RESOLUTION=1920x1080 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --mount type=bind,source=/var/run/dbus/system_bus_socket,target=/var/run/dbus/system_bus_socket \
  --name justx paulruvolo/testneato
