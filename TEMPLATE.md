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
| Chroma | see `_reports/round13/184-chromadb.md` | grows with loaded HNSW indexes |
| Chroma Gateway | see report | 20–40 MB |

Runs on every plan for small collections; about $1–2/month idle.

## Verification checklist

See `_reports/round13/184-chromadb.md`: health of both services, 401 without token, collection create/add/query through the gateway with both header formats, persistence after redeploy, short-token lock.

## Open questions

- No backup service: a Railway volume can only be mounted by one service, and Chroma 1.x has no export API. README points to Railway volume backups.
