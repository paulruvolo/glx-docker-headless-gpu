#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./start_rnw.sh instance-id"
    exit 1
fi
let "NO_VNC_PORT=40001 + $1"

DISPLAY_NUM=$(echo $DISPLAY | sed 's/^.//')

# remap the active display (assumed to be the one for 3d rendering) to :0 to avoid having to modify the container
docker run --rm \
  -d --gpus all \
  -p $NO_VNC_PORT:8081 \
  -v /tmp/.X11-unix/X$DISPLAY_NUM:/tmp/.X11-unix/X0:rw \
  -it qeasim450
