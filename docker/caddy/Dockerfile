FROM caddy:2.11-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddyserver/cache-handler \
    --with github.com/darkweak/storages/otter/caddy

FROM caddy:2.11-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
