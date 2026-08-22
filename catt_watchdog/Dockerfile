FROM ghcr.io/home-assistant/base:latest

ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN \
    apk add --no-cache \
        python3 \
        py3-pip \
        gcc \
        musl-dev \
        libffi-dev

RUN \
    pip3 install \
        --no-cache-dir \
        catt

COPY run.sh /run.sh

RUN chmod a+x /run.sh

LABEL \
    io.hass.type="app" \
    io.hass.arch="aarch64"

CMD ["/run.sh"]
