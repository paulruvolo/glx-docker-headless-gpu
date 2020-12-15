#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./start_rnw.sh instance-id"
    exit 1
fi
let "NO_VNC_PORT=40001 + $1"

# remap :1 to :0 to avoid having to modify the container (could just use $DISPLAY to figure out the right x-server)
docker run --rm \
  -d --gpus all \
  -p $NO_VNC_PORT:8081 \
  -v /tmp/.X11-unix/X1:/tmp/.X11-unix/X0:rw \
  -it qeasim450
