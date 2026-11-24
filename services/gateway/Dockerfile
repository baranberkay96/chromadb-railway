# Chroma Gateway: Caddy 2.11 with a token check in front of the private Chroma
# service. Pinned by tag and digest.
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0

COPY Caddyfile /etc/caddy/Caddyfile
COPY --chmod=0755 gateway-start.sh /usr/local/bin/gateway-start

# Fail the build if the Caddyfile does not parse (with sample values).
RUN PORT=8080 CHROMA_AUTH_TOKEN=build-check-token-0123456789 CHROMA_UPSTREAM=localhost:8000 \
    caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile \
 && sh -n /usr/local/bin/gateway-start

ENTRYPOINT ["/usr/local/bin/gateway-start"]
