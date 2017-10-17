FROM python:3.6-alpine

ENV GOSU_VERSION=1.10
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64 /usr/bin/gosu

COPY group /etc/group
COPY requirements.txt /

RUN apk add --no-cache \
        git \
        make && \
    chmod +x /usr/bin/gosu && \
    pip install \
        -r /requirements.txt

ADD ./entrypoint.sh /

WORKDIR /code

ENTRYPOINT ["/entrypoint.sh"]
