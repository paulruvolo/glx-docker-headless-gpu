#!/bin/bash

/opt/TurboVNC/bin/vncserver -SecurityTypes None
DISPLAY_NUM=`/opt/TurboVNC/bin/vncserver -list | grep -m 1 "^:" | sed 's/^:\([0-9]*\).*/\1/'`
export DISPLAY=:$DISPLAY_NUM
xsetroot -solid grey
/usr/bin/lxsession -s Lubuntu &

let "VNC_PORT=5900 + $DISPLAY_NUM"
# 3. start noVNC
/noVNC-1.1.0/utils/launch.sh --vnc localhost:$VNC_PORT --listen 8081 --cert /root/self.pem
