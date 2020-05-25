FROM qeasimnvidia435

RUN perl -pi -e 's/^Exec=terminator -e "vglrun bash"$/Exec=terminator/g' /usr/share/applications/terminator.desktop	

RUN cp /usr/share/applications/terminator.desktop /etc/xdg/autostart

COPY run.sh /run.sh
CMD ["bash", "/run.sh"]
