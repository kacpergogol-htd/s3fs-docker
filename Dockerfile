FROM ubuntu:18.04
 
ENV DUMB_INIT_VER 1.2.4
ENV S3_BUCKET ''
ENV MNT_POINT /data
ENV S3_REGION ''
ENV AWS_KEY ''
ENV AWS_SECRET_KEY ''
ENV PUBLIC_KEY ''
 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update --fix-missing && \
    apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev wget \
                       libfuse-dev libssl-dev libxml2-dev make pkg-config openssh-server && \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse && \
    cd /tmp/s3fs-fuse && ./autogen.sh && ./configure --prefix=/usr && make && make install && \
    ldconfig && /usr/bin/s3fs --version && \
    wget -O /tmp/dumb-init_${DUMB_INIT_VER}_amd64.deb https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64.deb && \
    dpkg -i /tmp/dumb-init_*.deb
 
#RUN echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs && \
#    cmod 0400 /etc/passwd-s3fs

RUN mkdir -p /root/.ssh/ && \
    mkdir -p /var/log/ssh/ && \
    mkdir -p /var/run/sshd && \
    echo "${PUBLIC_KEY}" > /root/.ssh/authorized_keys && \
    chmod 0400 /root/.ssh/authorized_keys
 
RUN mkdir -p "$MNT_POINT"
 
RUN DEBIAN_FRONTEND=noninteractive apt-get purge -y wget automake autotools-dev g++ git make && \
    apt-get -y autoremove --purge && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
# Runs "/usr/bin/dumb-init -- CMD_COMMAND_HERE"
#ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE 22

USER root

#ENTRYPOINT ["/usr/local/bin/dumb-init", "/usr/sbin/sshd", "-D", "-E", "/var/log/ssh/sshd.log", "-o", "PermitRootLogin=yes"]

COPY entrypointd.sh /usr/local/bin/
COPY entrypoint.d/ /etc/entrypoint.d/
RUN chmod +x /usr/local/bin/entrypointd.sh
RUN chmod -R +x /etc/entrypoint.d

ENTRYPOINT ["/usr/local/bin/entrypointd.sh"]
 
CMD ["/usr/bin/dumb-init", "/usr/sbin/sshd", "-D", "-E", "/var/log/ssh/sshd.log", "-o", "PermitRootLogin=yes"]
