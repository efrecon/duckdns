
ARG ALPINEVER=3.12.1
FROM alpine:${ALPINEVER}

RUN apk add --no-cache tini

# OCI Annotation: https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="duckdns"
LABEL org.opencontainers.image.description="DuckDNS updater"
LABEL org.opencontainers.image.authors="Emmanuel Frecon <efrecon+github@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/efrecon/duckdns"
LABEL org.opencontainers.image.documentation="https://github.com/efrecon/duckdns/README.md"
LABEL org.opencontainers.image.source="https://github.com/efrecon/duckdns"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.licenses="MIT"

ADD duckdns.sh /usr/local/bin/duckdns.sh

ENTRYPOINT [ "tini", "--", "/usr/local/bin/duckdns.sh" ]