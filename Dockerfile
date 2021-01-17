FROM amazon/aws-cli:latest
RUN amazon-linux-extras install epel && \
    yum install -y wget shadow-utils util-linux && \
    yum install -y https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/f/fswatch-1.14.0-3.el8.x86_64.rpm && \
    wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.4/dumb-init_1.2.4_x86_64 && \
    chmod +x /usr/bin/dumb-init

COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -s /usr/local/bin/docker-entrypoint.sh / && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    useradd -l -u 33 -g tape tape

USER tape

ENTRYPOINT ["docker-entrypoint.sh"]

#ENTRYPOINT ["/usr/bin/dumb-init", "--"]
#CMD ["docker-entrypoint.sh"]
