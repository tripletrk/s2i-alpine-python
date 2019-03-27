FROM python:3.6-alpine

ENV SUMMARY="Base alpine image with python3 which allows using of source-to-image." \
    DESCRIPTION="The s2i-python-alpine image provides any images layered on top of it \
and all the tools needed to use source-to-image functionality." 

ENV \
    # DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    APP_ROOT=/opt/app-root \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:$PATH

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Python 3.6 alpine" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      name="tripletrk/s2i-python-alpine" \
      version="1" \
      maintainer="Tripletrk <<tripletrk@bonafide.consulting>>"

RUN mkdir -p ${HOME} && \
    mkdir -p /usr/libexec/s2i && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 /opt/app-root && \
    apk add --no-cache --update curl wget ca-certificates && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
    apk -U upgrade && \
    update-ca-certificates --fresh && \ 
    rm -rf /var/cache/apk/*

# Copy executable utilities
COPY ./bin/ /usr/bin/

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

CMD ["base-usage"]