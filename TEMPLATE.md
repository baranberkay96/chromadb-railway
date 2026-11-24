# Chroma 1.5 Vector Database: Railway template spec

## Listing

| Field | Value |
|---|---|
| Name | **Chroma 1.5 Vector Database** (26 chars) |
| Description | Chroma vector database for RAG and embeddings, behind token auth. (65 chars) |
| Category | AI/ML |
| Tags | chroma, chromadb, vector-database, embeddings, rag, ai, llm |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/chroma.svg` (200, image/svg+xml) |

## Base market templates

| Market template | Topology | Kept | Problems fixed |
|---|---|---|---|
| `kbvIRV` "ChromaDB" (325 active) | `chromadb/chroma:1.5.9` + repo `FraglyG/CaddyAuthProxy` | Chroma 1.5.9 image, `/data` volume, Caddy token proxy idea | Chroma service config keys that 1.x ignores (`CHROMA_HOST_ADDR`, `CHROMA_HOST_PORT`, `CHROMA_WORKERS`), no healthcheck on Chroma, proxy only accepts its own bearer format |
| `tifygm` "Chroma" (88 active) | `ghcr.io/chroma-core/chroma:0.4.5` | | Two years old, no auth at all |
| `Vlo43b` "ChromaDB" (16 active) | `chromadb/chroma:0.5.23` with built-in token auth | Token auth idea | 0.5 line; 1.x removed server-side auth |

### Improvements over market templates

1. Chroma 1.5.9 configured with the keys the Rust server actually reads (`CHROMA_PORT`, `CHROMA_LISTEN_ADDRESS=::`, `CHROMA_PERSIST_PATH`), private only, healthcheck `/api/v2/heartbeat`.
2. Token gateway (Caddy 2.11.9) that accepts both of Chroma's client header formats (`Authorization: Bearer`, `X-Chroma-Token`), leaves heartbeat/version open, and answers 401 with a JSON hint otherwise.
3. Fail-closed token handling (missing/short token → random lock, log explains; 8.29).
4. Private URL for apps in the same project (no token needed inside the private network).

## Pinned versions (checked 2026-11-24)

| Service | Image | Version |
|---|---|---|
| Chroma | `chromadb/chroma:1.5.9` (digest `sha256:1e0b73a1…`, released 2026-05-05; newest stable, later tags are dev builds) | Chroma 1.5.9 |
| Chroma Gateway | repo `services/gateway`, `FROM caddy:2.11.9-alpine@sha256:003a9780…` | Caddy 2.11.9 |

## Resources and cost

| Service | Idle RAM | Typical |
|---|---|---|
| Chroma | 12 MB (measured, empty) | grows with loaded HNSW indexes |
| Chroma Gateway | 55 MB (measured) | 50–80 MB |

Runs on every plan for small collections; under $1/month idle.

## Verification checklist

- [x] Both services SUCCESS; Chroma healthcheck `/api/v2/heartbeat` over IPv4 with `CHROMA_LISTEN_ADDRESS=::` (dual stack); gateway `/healthz` 200.
- [x] Heartbeat and version open; collections endpoint 401 without token and with a wrong token.
- [x] REST through the gateway: collection created (Bearer), 3 embeddings added and queried (X-Chroma-Token), count 3.
- [x] Official `chromadb-client` 1.5.9: `HttpClient(headers={"Authorization": "Bearer ..."})` add + query; `Settings(chroma_client_auth_provider=TokenAuthClientProvider, chroma_auth_token_transport_header="X-Chroma-Token")` lists collections; a client without token is refused.
- [x] `CHROMA_AUTH_TOKEN=short`: deploy SUCCESS, gateway locked (old and short tokens 401), log explains; restoring the token works.
- [x] Collections persisted across a Chroma redeploy.

## Open questions

- No backup service: a Railway volume can only be mounted by one service, and Chroma 1.x has no export API. README points to Railway volume backups.
