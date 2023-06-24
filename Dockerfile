FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

# Install necessary packages
RUN apt-get update && \
    apt-get install -y xfce4 xrdp wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ngrok
RUN RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip && \
    unzip /ngrok.zip -d / && \
    rm /ngrok.zip

# Set ngrok auth token
ENV NGROK_AUTH_TOKEN=2JaiAWKOJhh7FRWIdIGWWEhEl3O_6PHCFHKnMfuZUsJd2NZp5

# Configure RDP session
RUN sed -i 's/^new_cursors=true/new_cursors=false/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/^crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/^#xserverbpp=24/xserverbpp=32/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/^#max_bpp=24/max_bpp=32/g' /etc/xrdp/xrdp.ini && \
    echo "xfce4-session" > /etc/skel/.xsession && \
    echo "session required pam_unix.so" | tee -a /etc/pam.d/xrdp-sesman

# Allow root login via RDP
RUN sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    echo 'root:kinosan' | chpasswd

# Set keyboard layout to Indonesian
RUN sed -i 's/^#XKBLayout=X/XKBLayout=id/g' /etc/default/keyboard

# Expose RDP and ngrok ports
EXPOSE 3389
EXPOSE 4040

# Start ngrok and xrdp on container startup
CMD /ngrok authtoken 2JaiAWKOJhh7FRWIdIGWWEhEl3O_6PHCFHKnMfuZUsJd2NZp5 && \
    /ngrok tcp --region=jp 3389 & \
    service xrdp start && \
    tail -f /dev/null
