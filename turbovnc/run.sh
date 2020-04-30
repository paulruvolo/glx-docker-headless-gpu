#!/bin/bash

/opt/TurboVNC/bin/vncserver -SecurityTypes None

# 3. start noVNC
/noVNC-1.1.0/utils/launch.sh --vnc localhost:5901 --listen 8081 --cert /root/self.pem &
sleep 2

echo 'running noVNC at http://localhost:8081/vnc.html?host=localhost&port=8081'
export DISPLAY=:1
xsetroot -solid grey
/usr/bin/lxsession -s Lubuntu
