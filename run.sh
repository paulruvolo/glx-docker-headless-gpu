# inside docker script
trap 'kill $(jobs -p)' EXIT

dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

# 0. generate xorg.conf
BUS_ID=$(nvidia-xconfig --query-gpu-info | grep 'PCI BusID' | sed -r 's/\s*PCI BusID : PCI:(.*)/\1/')
nvidia-xconfig -a --virtual=$RESOLUTION --allow-empty-initial-configuration --enable-all-gpus --busid $BUS_ID

# fix DPI
sed -i.bak -e 's/"DPMS"/"DPMS"\n    Option "DPI" "96x96"\n/' /etc/X11/xorg.conf
# 1. launch X server
Xorg :0
