FROM alpine:3.7

RUN apk add --update --no-cache \
    ca-certificates \
    && rm -rf /var/cache/apk/*

COPY xxx /usr/local/bin/xxx
COPY docker-entrypoint /usr/local/bin/

WORKDIR /usr/local/var/xxx

EXPOSE 8080 8081
VOLUME ["/opt", "/usr/local/etc/xxx"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
