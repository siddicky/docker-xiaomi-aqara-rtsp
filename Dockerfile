FROM python:3-stretch

WORKDIR /usr/src/app

# Update sources to archived repositories and remove stretch-updates
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get -y dist-upgrade && \
    apt-get -y install liblivemedia-dev libjson-c-dev

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Upgrade pip to the latest version
RUN python3 -m pip install --upgrade pip

# Install an older version of cryptography that doesn't require Rust
RUN python3 -m pip install cryptography==3.3.2

# Install a compatible version of python-miio
RUN python3 -m pip install python-miio==0.5.4

# Clone code
RUN git clone https://github.com/miguelangel-nubla/videoP2Proxy.git .

# Build code
RUN ./autogen.sh
RUN make
RUN make install

# Run code
CMD videop2proxy --ip $IP --token $TOKEN --rtsp 8554

# Expose port
EXPOSE 8554