# Configuration

MemLoop reads configuration from environment variables. By default it loads a
local `.env` file from `MEMLOOP_REPO_ROOT` or the current working directory.

## Environment Files

```bash
cp .env.example .env
```

Set `MEMLOOP_ENV_FILE` when you want to keep configuration outside the project
directory:

```bash
export MEMLOOP_ENV_FILE=/secure/path/memloop.env
```

## API Settings

| Variable | Required for | Notes |
| --- | --- | --- |
| `MEMLOOP_API_BASE_URL` | Model-backed answering and judging | OpenAI-compatible chat-completions base URL. |
| `MEMLOOP_API_KEY` | Model-backed answering and judging | API key for your model gateway. |
| `MEMLOOP_API_MODEL` | Model-backed answering and judging | Chat model name or deployment alias. |
| `MEMLOOP_EMBED_API_BASE_URL` | API-backed embeddings | Optional OpenAI-compatible embedding endpoint. |
| `MEMLOOP_EMBED_API_KEY` | API-backed embeddings | Optional embedding API key. |
| `MEMLOOP_EMBED_API_MODEL` | API-backed embeddings | Optional embedding model or deployment alias. |
| `MEMLOOP_EMBED_DIM` | API-backed embeddings | Optional embedding dimension override. |

MemLoop's default public configuration is provider-neutral. Advanced deployments
can still add project-specific provider aliases in `memloop.core.api_adapter`
when they need a custom gateway, tenancy layer, or hosted model runtime.

## Retrieval Settings

| Variable | Default | Notes |
| --- | --- | --- |
| `MEMLOOP_EMBED_BACKEND` | `minilm` | Local embedding backend for development. |
| `MEMLOOP_L0_RETRIEVAL` | `bm25` | L0 candidate retrieval mode. |
| `MEMLOOP_SKIP_L0_EMBED` | `0` | Set to `1` to avoid embedding all L0 nodes. |
| `MEMLOOP_INDEX_CACHE_DIR` | unset | Optional cache directory for retrieval indexes. |
| `MEMLOOP_ANSWER_MODE` | runner default | Use `detailed_truncated` for compact evidence contexts. |

## Secret Policy

Do not commit `.env`, generated JSONL answers, parquet manifests, logs, caches,
or provider keys. `.gitignore` already excludes common local artifacts.
