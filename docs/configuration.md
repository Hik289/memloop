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

## Provider Settings

| Variable | Required for | Notes |
| --- | --- | --- |
| `AZURE_OPENAI_ENDPOINT` | Azure LLM calls | Endpoint URL for Azure deployments. |
| `AZURE_LLM_API_KEY` | Azure LLM calls | Preferred key name for MemLoop. |
| `AZURE_OPENAI_KEY` | Azure LLM calls | Fallback key name. |
| `AWS_BEDROCK_API_KEY` | Bedrock response calls | Used by Bedrock-compatible aliases. |
| `BEDROCK_MODEL_GPT54` | Bedrock response calls | Optional model override. |

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
