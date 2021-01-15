FROM python:slim

ENV DUMB_INIT_VER 1.2.4 
ENV PUBLIC_KEY ''
 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update --fix-missing && \
    apt-get install -y automake autotools-dev g++ git libcurl4-gnutls-dev wget \
                       libfuse-dev libssl-dev libxml2-dev make pkg-config openssh-server && \
    wget -O /tmp/dumb-init_${DUMB_INIT_VER}_amd64.deb https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64.deb && \
    dpkg -i /tmp/dumb-init_*.deb
 
RUN mkdir -p /root/.ssh/ && \
    mkdir -p /var/log/ssh/ && \
    mkdir -p /var/run/sshd && \
    echo "${PUBLIC_KEY}" > /root/.ssh/authorized_keys && \
    chmod 0400 /root/.ssh/authorized_keys && \
    pip install mobius3
 
RUN DEBIAN_FRONTEND=noninteractive apt-get purge -y wget automake autotools-dev g++ git make && \
    apt-get -y autoremove --purge && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
EXPOSE 22

USER root

COPY entrypointd.sh /usr/local/bin/
COPY entrypoint.d/ /etc/entrypoint.d/
RUN chmod +x /usr/local/bin/entrypointd.sh
RUN chmod -R +x /etc/entrypoint.d

ENTRYPOINT ["/usr/local/bin/entrypointd.sh"]
 
CMD ["/usr/bin/dumb-init", "/usr/sbin/sshd", "-D", "-E", "/var/log/ssh/sshd.log", "-o", "PermitRootLogin=yes"]
