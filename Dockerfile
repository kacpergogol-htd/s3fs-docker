FROM amazon/aws-cli:latest
RUN amazon-linux-extras install epel
RUN yum install -y https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/f/fswatch-1.14.0-3.el8.x86_64.rpm
RUN yum install -y shadow-utils

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN useradd -l -u 33 -g tape tape

USER tape

ENTRYPOINT ["docker-entrypoint.sh"]
