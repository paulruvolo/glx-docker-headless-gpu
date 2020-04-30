#!/bin/bash
docker build -t turbovnc . && \
docker run --rm \
  --gpus all \
  -p 40001:8081 \
  -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:rw \
  --mount type=bind,source=/usr/local/MATLAB,target=/usr/local/MATLAB,readonly \
  --name turbovnc -it turbovnc
