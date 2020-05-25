#!/bin/bash
docker run --privileged -d --rm --gpus all \
  -e RESOLUTION=1920x1080 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --name justx justx435
