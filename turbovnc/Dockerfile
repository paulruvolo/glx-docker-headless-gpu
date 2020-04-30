FROM paulruvolo/testneato

# Supress interactive menu while installing keyboard-configuration
ARG DEBIAN_FRONTEND=noninteractive

ARG SOURCEFORGE=https://sourceforge.net/projects
ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.6.3


RUN cd /tmp && \
    curl -fsSL -O ${SOURCEFORGE}/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb

# Precede bash on all new terminator shells with vglrun so that 3d graphics apps will use the GPU
RUN perl -pi -e 's/^Exec=terminator$/Exec=terminator -e "vglrun bash"/g' /usr/share/applications/terminator.desktop	

# make sure to start new terminator shell upon connection
RUN cp /usr/share/applications/terminator.desktop /etc/xdg/autostart/

# put a desktop shortcut
COPY terminator.desktop /root/Desktop

COPY index.html /noVNC-1.1.0/index.html

COPY run.sh /run.sh
CMD ["bash", "/run.sh"]
