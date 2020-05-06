FROM paulruvolo/testneato

# Supress interactive menu while installing keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

# Precede bash on all new terminator shells with vglrun so that 3d graphics apps will use the GPU
RUN perl -pi -e 's/^Exec=terminator$/Exec=terminator -e "vglrun bash"/g' /usr/share/applications/terminator.desktop	

# make sure to start new terminator shell upon connection
RUN cp /usr/share/applications/terminator.desktop /etc/xdg/autostart/

# put a desktop shortcut
COPY terminator.desktop /root/Desktop

COPY index.html /noVNC-1.1.0/index.html

COPY run.sh /run.sh
CMD ["bash", "/run.sh"]
