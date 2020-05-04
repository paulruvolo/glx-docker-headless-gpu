#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./start_rnw.sh instance-id"
    exit 1
fi
let "NO_VNC_PORT=40001 + $1"

docker run --rm \
  --gpus all \
  -p $NO_VNC_PORT:8081 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --mount type=bind,source=/usr/local/MATLAB,target=/usr/local/MATLAB,readonly \
  -it paulruvolo/testneato:turbovnc
