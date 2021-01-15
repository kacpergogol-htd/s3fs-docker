#!/bin/bash
mkdir -p /root/.ssh/ && \
    echo "${PUBLIC_KEY}" > /root/.ssh/authorized_keys && \
    chmod 0400 /root/.ssh/authorized_keys
