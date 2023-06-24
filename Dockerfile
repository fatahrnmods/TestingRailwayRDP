FROM ubuntu:jammy

SHELL ["/bin/bash", "-c"]

# Update package repository and install necessary packages
RUN apt-get update && \
    apt-get install -y xfce4 xrdp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Expose RDP port
EXPOSE 3389

# Start xrdp service on container startup
CMD service xrdp start && tail -f /dev/null
