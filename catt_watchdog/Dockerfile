FROM ghcr.io/home-assistant/aarch64-base:latest

ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN apk add --no-cache \
    python3 \
    py3-pip \
    gcc \
    musl-dev \
    libffi-dev \
    curl

RUN pip3 install --no-cache-dir catt

COPY run.sh /run.sh

RUN chmod a+x /run.sh

CMD ["/run.sh"]
