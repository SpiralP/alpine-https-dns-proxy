FROM alpine AS https-dns-proxy-builder

RUN set -ex \
    && apk add --no-cache alpine-sdk \
    && adduser nobody abuild


RUN set -ex \
    && cd /tmp \
    && wget -O - 'https://gitlab.alpinelinux.org/alpine/aports/-/archive/master/aports-master.tar.gz' | tar -xzf -

COPY --chown=nobody:nobody https-dns-proxy /tmp/aports-master/community/https-dns-proxy

RUN set -ex \
    && cd /tmp/aports-master/community/https-dns-proxy \
    && abuild -F deps


USER nobody

RUN set -ex \
    && cd /tmp/aports-master/community/https-dns-proxy \
    && HOME=/tmp abuild-keygen --append -n \
    && HOME=/tmp abuild


FROM alpine AS https-dns-proxy
COPY --from=https-dns-proxy-builder /tmp/packages /packages

RUN find /packages/ -name '*.apk' -print0 | xargs -0 -t -n1 apk add --allow-untrusted
