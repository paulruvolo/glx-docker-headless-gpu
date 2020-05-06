#!/bin/bash

if [[ -z "${WAITX}" ]]; then
  WAITX="X0"
fi

# wait for a particular X socket to become available
while [[ ! -S /tmp/.X11-unix/${WAITX} ]]
do
    sleep 5
done

/opt/TurboVNC/bin/vncserver -SecurityTypes None
DISPLAY_NUM=`/opt/TurboVNC/bin/vncserver -list | grep -m 1 "^:" | sed 's/^:\([0-9]*\).*/\1/'`
let "VNC_PORT=5900 + $DISPLAY_NUM"

# 3. start noVNC
/noVNC-1.1.0/utils/launch.sh --vnc localhost:$VNC_PORT --listen 8081 --cert /root/self.pem &
sleep 2

echo 'running noVNC at http://localhost:8081/vnc.html?host=localhost&port=8081'
export DISPLAY=:$DISPLAY_NUM
xsetroot -solid grey
/usr/bin/lxsession -s Lubuntu
