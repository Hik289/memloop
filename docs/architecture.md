# Architecture

MemLoop is organized as a local-first retrieval package. It keeps data
preparation, retrieval control, answer generation, and evaluation in separate
layers so teams can replace storage, model gateways, and orchestration without
rewriting the full pipeline.

## Runtime Layers

| Layer | Purpose | Primary modules |
| --- | --- | --- |
| Data plane | Read evidence manifests, build hierarchy nodes, and persist local artifacts. | `memloop.data`, `memloop.methods.dual_node` |
| Retrieval plane | Search L0 evidence, navigate hierarchy nodes, promote useful detail, and assemble answer context. | `memloop.methods`, `memloop.runners` |
| Operations plane | Load provider configuration, track token use, run evaluations, and expose CLI entry points. | `memloop.core`, `memloop.eval`, `memloop.cli` |

## Query Lifecycle

1. Load hierarchy and query manifest.
2. Retrieve L0 candidates with the configured retrieval backend.
3. Navigate hierarchy nodes to choose a query-specific active path.
4. Promote detailed evidence when compact memory is not enough.
5. Build the answer context from compact and detailed memory.
6. Write answer, citation, token, and evaluation artifacts to the run directory.

## Extension Points

| Extension | How to customize |
| --- | --- |
| Model gateway | Configure OpenAI-compatible chat and embedding endpoints with environment variables. |
| Retrieval backend | Use BM25 by default; extend index code under `memloop.methods` for alternative retrieval. |
| Storage | Keep manifests in local parquet/JSONL files, or wrap reads and writes before calling the CLI modules. |
| Evaluation | Add custom metrics under `memloop.eval` and expose them through the CLI. |
| Orchestration | Run the CLI from Airflow, cron, batch systems, notebooks, or service workers. |

## Artifact Boundaries

MemLoop assumes private corpora, generated answers, caches, and logs are local
runtime artifacts. They are intentionally ignored by Git. Public commits should
contain package code, small fixtures, docs, and reproducible command surfaces,
not customer data or generated benchmark output.
