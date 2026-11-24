# NOTICE

This Railway template is a community package. It is not affiliated with or endorsed by Chroma (Chroma Inc.), the Caddy project or Railway.

## What this template runs

| Component | Source | License |
|---|---|---|
| Chroma 1.5.9 | official image `chromadb/chroma:1.5.9` (digest `sha256:1e0b73a1…`), https://github.com/chroma-core/chroma, used unmodified | Apache-2.0 |
| Caddy 2.11.9 | official image `caddy:2.11.9-alpine` (digest `sha256:003a9780…`) | Apache-2.0 |

## Files written for this template

- `services/gateway/Dockerfile`, `Caddyfile` (token check for `Authorization: Bearer` and `X-Chroma-Token`, open heartbeat/version, 401 otherwise) and `gateway-start.sh` (fail-closed token handling).
- `TEMPLATE.md`, `README.md`, `template.json`, this file.

## Reused or not reused

- The marketplace templates in `../_market/` (`kbvIRV` with `FraglyG/CaddyAuthProxy`, `tifygm`, `Vlo43b`) were read for settings only. The idea of a Caddy token proxy in front of Chroma 1.x comes from `kbvIRV`; its proxy repository was not used or copied (the Caddyfile here is written from Caddy's documentation and accepts Chroma's own client header formats).

## Upstream material checked (2026-11-24)

- `chroma-core/chroma` at tag `1.5.9`: `rust/frontend/sample_configs/docker_single_node.yaml` (`persist_path: /data`), `rust/frontend/src/config.rs` (`CHROMA_` environment overrides, `port`, `listen_address`), `rust/frontend/src/server.rs` (bind `{listen_address}:{port}`), image config (`dumb-init -- chroma run /config.yaml`).
- Chroma docs: client-server mode and client authentication headers (`Authorization: Bearer`, `X-Chroma-Token`).
