# Deploy and Host Chroma with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/chroma-15-vector-database?referralCode=20H68q)

Chroma is an open-source vector database for AI applications: it stores embeddings with documents and metadata and answers similarity searches for retrieval-augmented generation (RAG), semantic search and agent memory. This community template runs Chroma 1.5 on a persistent volume behind a small gateway that requires an API token, so the database is never open to the internet.

## About Hosting Chroma

Chroma's 1.x server is fast and simple, but it has no built-in authentication: a Chroma service with a public domain lets anyone read, change or delete your collections. This template keeps Chroma on Railway's private network and puts a Caddy gateway in front of it with a public HTTPS domain. The gateway accepts requests only with the generated token, sent exactly the way Chroma's own Python and JavaScript clients send it, and passes everything else through unchanged. Apps inside the same Railway project can talk to Chroma directly over the private network. Data lives on a volume and survives redeploys.

## Common Use Cases

- Retrieval-augmented generation: store document chunks and retrieve the most relevant ones for an LLM prompt
- Semantic search over docs, tickets, products or code
- Long-term memory for agents and chatbots built with LangChain, LlamaIndex or your own code
- Deduplication and clustering of text or image embeddings
- A shared vector store for several services in one Railway project

## Dependencies for Chroma Hosting

- Chroma server 1.5 (included: `chromadb/chroma:1.5.9`)
- Caddy 2.11 as the token gateway (included, built from this repo)

### Deployment Dependencies

- Chroma documentation: https://docs.trychroma.com/
- Chroma source: https://github.com/chroma-core/chroma
- Client authentication headers: https://docs.trychroma.com/docs/run-chroma/client-server
- Caddy documentation: https://caddyserver.com/docs/

### Implementation Details

| Service | Source | Purpose |
|---|---|---|
| Chroma | `chromadb/chroma:1.5.9` | Vector database, private only, volume at `/data`, healthcheck `/api/v2/heartbeat` |
| Chroma Gateway | built from this repo (`services/gateway`, `FROM caddy:2.11.9-alpine`) | Public HTTPS domain, checks the API token, forwards to Chroma over the private network |

**Connecting from Python** (`CHROMA_URL` and `CHROMA_AUTH_TOKEN` are on the Chroma Gateway service):

```python
import chromadb
client = chromadb.HttpClient(
    host="{your-gateway-domain}", port=443, ssl=True,
    headers={"Authorization": "Bearer {CHROMA_AUTH_TOKEN}"},
)
collection = client.get_or_create_collection("docs")
```

Chroma's token settings work too: `Settings(chroma_client_auth_provider="chromadb.auth.token_authn.TokenAuthClientProvider", chroma_client_auth_credentials="{token}")`, with either the default `Authorization` header or `chroma_auth_token_transport_header="X-Chroma-Token"`. In JavaScript, pass `headers: { Authorization: "Bearer {token}" }` to `ChromaClient`.

**Apps in the same Railway project** can skip the gateway and use `CHROMA_PRIVATE_URL` (`http://chroma.railway.internal:8000`), which is only reachable inside the project.

**First steps**

1. Check the gateway: `curl https://{your-gateway-domain}/api/v2/heartbeat` (open, returns a timestamp).
2. Check the token: `curl -H "Authorization: Bearer {token}" https://{your-gateway-domain}/api/v2/tenants/default_tenant/databases/default_database/collections` lists collections; without the header it returns 401.
3. Add documents from your app with your embedding model, or let Chroma's client compute embeddings locally.

**Security notes**: only `GET /api/v2/heartbeat`, `/api/v2/version` (and their v1 forms) and the gateway's `/healthz` are open. Rotate the token by changing `CHROMA_AUTH_TOKEN` on the gateway and redeploying it. A token shorter than 16 characters locks the gateway with a random token (the log explains) instead of opening it.

**Backups**: Chroma keeps a SQLite catalog and index files in `/data`. Use Railway's volume backups on the Chroma service (Backups tab) for scheduled snapshots, or export collections from your app. There is no separate backup service because a Railway volume can only be mounted by one service.

**Scaling**: Chroma holds the HNSW indexes of collections in use in memory; give the Chroma service more RAM as collections grow (roughly vectors × dimensions × 4 bytes plus overhead) and grow the volume. The gateway needs only a few MB.

**Versions and upgrades**: Chroma is pinned to 1.5.9 and Caddy to 2.11.9. Change the image tag on the Chroma service (and `services/gateway/Dockerfile` for Caddy) to upgrade; Chroma migrates its catalog on start, so take a volume backup first.

### Why Deploy Chroma on Railway?

Railway runs Chroma and its gateway together with a private network, a persistent volume and an HTTPS domain, so a protected vector database is ready for your RAG app in minutes. Services in the same project reach it privately by reference, and you scale it by raising the service limits.
