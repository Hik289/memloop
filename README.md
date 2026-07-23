# MemLoop

**Production-grade hierarchical memory retrieval for enterprise RAG systems.**

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-0E7C66.svg" alt="MIT license"></a>
  <a href="pyproject.toml"><img src="https://img.shields.io/badge/python-3.10%2B-1F4E79.svg" alt="Python 3.10+"></a>
  <a href=".github/workflows/ci.yml"><img src="https://img.shields.io/badge/ci-package%20checks-0E7C66.svg" alt="CI package checks"></a>
  <a href="pyproject.toml"><img src="https://img.shields.io/badge/cli-memloop-111827.svg" alt="memloop CLI"></a>
</p>

MemLoop is a Python package and CLI for teams building retrieval over long-lived
enterprise context: documents, tables, slides, tickets, code snippets, emails,
and other evidence that cannot fit into a single prompt. It builds a hierarchy
over raw evidence, routes each query through compact memory, promotes detailed
source evidence only when needed, and produces answer contexts that are easier
to inspect, evaluate, and operate.

<p align="center">
  <img src="assets/retrieval-pipeline.png" alt="MemLoop retrieval pipeline" width="78%">
</p>

## What MemLoop Provides

| Area | Production behavior |
| --- | --- |
| Retrieval control | BM25-first L0 retrieval, hierarchy navigation, and explicit evidence promotion. |
| Context efficiency | Compact `distilled_text` for breadth plus selected `detailed_text` for grounding. |
| Observability | Token accounting, promotion events, model aliases, answer files, and resumable run directories. |
| Evaluation | Answer quality, citation quality, retrieval-only, and ROUGE evaluation entry points. |
| Provider flexibility | Provider-neutral configuration for OpenAI-compatible chat and embedding gateways. |
| Data hygiene | Local manifests and generated outputs stay outside Git by default. |

## System Design

MemLoop separates the retrieval system into three layers:

| Layer | Responsibility | Key modules |
| --- | --- | --- |
| Data plane | Build L0 evidence, hierarchy nodes, and dual memory fields. | `memloop.data`, `memloop.methods.dual_node` |
| Retrieval plane | Search, navigate, promote, distill, and assemble answer context. | `memloop.methods`, `memloop.runners` |
| Operations plane | Load configuration, track tokens, run evaluations, and verify environments. | `memloop.core`, `memloop.eval`, `memloop.cli` |

The runtime path is intentionally coarse-to-fine:

1. Retrieve sparse L0 candidates.
2. Navigate hierarchy nodes to choose an active path.
3. Promote detailed evidence when the query needs source-level grounding.
4. Distill compact answer context.
5. Produce cited answers and evaluation artifacts.

## Install

```bash
git clone git@github.com:Hik289/memloop.git
cd memloop

python -m venv .venv
source .venv/bin/activate
pip install -e ".[all]"
```

For smaller environments:

```bash
pip install -e .              # core CLI and retrieval dependencies
pip install -e ".[local]"     # local sentence-transformer embeddings
pip install -e ".[llm,eval]"  # model providers and evaluation tools
```

Verify the package:

```bash
memloop doctor
```

## Quick Start

Create a small local dataset:

```bash
python examples/create_demo_dataset.py
```

Build a dry-run hierarchy:

```bash
memloop build-hierarchy \
  --tier demo \
  --l0_parquet examples/demo/manifests/l0_nodes.parquet \
  --out_dir examples/demo/results/hierarchy \
  --dry_run
```

Run a smoke retrieval job:

```bash
export MEMLOOP_EMBED_BACKEND=minilm
export MEMLOOP_L0_RETRIEVAL=bm25
export MEMLOOP_SKIP_L0_EMBED=1
export MEMLOOP_ANSWER_MODE=detailed_truncated

memloop run \
  --method V5 \
  --hierarchy examples/demo/results/hierarchy/hierarchy.json \
  --queries examples/demo/manifests/queries.parquet \
  --out examples/demo/results/runs/V5 \
  --n_smoke 5 \
  --resume
```

Evaluate generated answers when a gold file is available:

```bash
memloop evaluate \
  --answers examples/demo/results/runs/V5/answers.jsonl \
  --gold examples/demo/manifests/gold.jsonl \
  --out examples/demo/results/runs/V5/eval \
  --resume
```

## Production Workflow

| Step | Command or artifact | Operational note |
| --- | --- | --- |
| Prepare manifests | `manifests/l0_nodes.parquet`, `queries.parquet`, `gold.jsonl` | Keep private data outside Git. |
| Build hierarchy | `memloop build-hierarchy` | Store hierarchy outputs under `results/hierarchy/`. |
| Run retrieval | `memloop run` or `memloop run-v6` | Use `--resume` for long jobs. |
| Evaluate | `memloop evaluate`, `memloop eval-retrieval`, `memloop eval-rouge` | Keep raw answers and reports as local artifacts. |
| Inspect operations | Token ledger, promotion state, answer JSONL, logs | Track model alias, seed, tier, and git commit. |

## Core Concepts

<p align="center">
  <img src="assets/path-search.png" alt="Search a path through the hierarchy" width="80%">
</p>

**Query-specific paths.** A query does not expand the full tree. MemLoop first
retrieves a broad candidate set, chooses a narrow hierarchy path, and carries
forward only evidence that helps answer the current request.

<p align="center">
  <img src="assets/on-demand-promotion.png" alt="On-demand evidence promotion" width="80%">
</p>

**On-demand promotion.** The system avoids prebuilding every detailed summary.
Detailed evidence is promoted after parent-level routing identifies useful
branches, keeping answer context within a predictable budget.

<p align="center">
  <img src="assets/dual-memory.png" alt="Dual detailed and distilled memory" width="80%">
</p>

**Two memory views.** Detailed memory is optimized for inspection and grounding.
Distilled memory is optimized for routing and compact final answer context.

## Data Contract

MemLoop reads local files. It does not commit private corpora, generated answer
logs, caches, or model outputs.

| File | Format | Required fields |
| --- | --- | --- |
| L0 evidence | parquet | `doc_id`, `source_type`, `title`, `content`, `text` |
| Queries | parquet | `query_id`, `query_text` |
| Gold labels | JSONL | `query_id` or `question_id`, `expected_doc_ids`, `gold_answer` |

Recommended project layout:

```text
manifests/
  l0_nodes.parquet
  queries.parquet
  gold.jsonl
results/
  hierarchy/
  runs/
```

## Configuration

Copy the template and fill in only the providers you use:

```bash
cp .env.example .env
```

| Variable | Purpose |
| --- | --- |
| `MEMLOOP_REPO_ROOT` | Project directory used for `.env`, manifests, results, and caches. |
| `MEMLOOP_ENV_FILE` | Optional explicit path to an environment file. |
| `MEMLOOP_API_BASE_URL` | OpenAI-compatible chat-completions base URL. |
| `MEMLOOP_API_KEY` | API key for the configured model gateway. |
| `MEMLOOP_API_MODEL` | Chat model name or deployment alias. |
| `MEMLOOP_EMBED_BACKEND` | `minilm` for local embeddings, or a configured API-backed backend. |
| `MEMLOOP_EMBED_API_BASE_URL` | Optional OpenAI-compatible embedding endpoint. |
| `MEMLOOP_EMBED_API_KEY` | Optional embedding API key. |
| `MEMLOOP_EMBED_API_MODEL` | Optional embedding model or deployment alias. |
| `MEMLOOP_L0_RETRIEVAL` | `bm25` by default; dense reranking can be enabled separately. |
| `MEMLOOP_SKIP_L0_EMBED` | Set to `1` to avoid embedding every L0 node. |
| `MEMLOOP_INDEX_CACHE_DIR` | Optional cache directory for retrieval indexes. |

Secrets belong in `.env`, your process environment, or a deployment secret
manager. Do not commit real keys, parquet manifests, JSONL answers, logs,
caches, or generated run outputs.

## CLI Reference

```bash
memloop doctor             # check local package and optional dependencies
memloop build-hierarchy    # build L0-Ln memory hierarchy
memloop run                # run the V5 retrieval and answer pipeline
memloop run-v6             # run the dual-memory V6 wrapper
memloop evaluate           # evaluate answers with citation labels
memloop eval-retrieval     # evaluate retrieval only
memloop eval-rouge         # compute ROUGE metrics locally
memloop api-smoke          # test configured provider calls
```

The scripts in `scripts/` are batch launchers built on these package entry
points. Prefer the `memloop` CLI in new automation.

## Python API

```python
from memloop.methods import (
    DecayController,
    DualNode,
    PromotionController,
    TokenLedger,
    read_nodes_jsonl,
)

nodes = {
    node.node_id: node
    for node in read_nodes_jsonl("results/hierarchy/demo/hierarchy.json")
}

ledger = TokenLedger(run_id="demo", method="V5")
promotion = PromotionController(nodes, embedder=None, promotion_budget=20)
decay = DecayController(nodes, decay_window=15)
```

Use the CLI for full runs and the Python API for integration tests, custom
storage adapters, dashboards, schedulers, or model gateways.

## Repository Layout

```text
memloop/
  core/       provider adapter, environment loading, config templates
  data/       hierarchy construction and data preparation
  methods/    node schema, indexes, promotion, decay, token ledger
  runners/    retrieval and answer-generation pipelines
  eval/       answer, citation, retrieval, and ROUGE evaluation
assets/      README and documentation figures
docs/        architecture, quickstart, configuration, data contract, operations
examples/    demo dataset generator
tests/       package and CLI smoke tests
scripts/     batch launchers
```

## Documentation

- [Architecture](docs/architecture.md)
- [Quickstart](docs/quickstart.md)
- [Configuration](docs/configuration.md)
- [Data contract](docs/data-contract.md)
- [Production checklist](docs/production.md)
- [Operations guide](docs/ARTIFACT.md)

## Development

```bash
pip install -e ".[dev]"
python -m compileall -q memloop
pytest
python -m build
```

Optional convenience commands:

```bash
make install-dev
make test
make build
```

Before pushing public changes:

```bash
rg -n --hidden -S "(sk-[A-Za-z0-9]|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|PRIVATE)|Bearer [A-Za-z0-9._+/=-]{20,})" .
rg -n "LOCAL_PATH|PRIVATE_PATH|REPLACE_ME" .
```

## Citation

```bibtex
@software{memloop2026,
  title  = {MemLoop: Hierarchical Memory Retrieval with Event-Driven Evidence Promotion},
  author = {MemLoop Authors},
  year   = {2026},
  url    = {https://github.com/Hik289/memloop}
}
```

## License

MIT. See [LICENSE](LICENSE).
