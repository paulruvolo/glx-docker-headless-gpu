#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "./start_rnw.sh instance-id"
    exit 1
fi
let "NO_VNC_PORT=40001 + $1"

# If you use the containers in ECS, then MATLAB is already installed
docker run --rm \
  -p $NO_VNC_PORT:8081 \
  -it qeasimnogpu
