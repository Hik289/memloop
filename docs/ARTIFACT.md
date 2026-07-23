# Operations Guide

Operational notes for running MemLoop from the public package repository.

## Review Path

- `memloop/core/`: Provider adapter, environment loading, and config templates.
- `memloop/eval/`: Answer, citation, retrieval, and ROUGE evaluation.
- `memloop/methods/`: Node schema, indexes, promotion, decay, and accounting.
- `memloop/runners/`: Retrieval and answer-generation pipelines.
- `memloop/data/`: Hierarchy construction and data preparation utilities.
- `scripts/`: Batch launchers built on package entry points.
- `docs/architecture.md`: Runtime layers, query lifecycle, and extension points.
- `docs/production.md`: Deployment, secrets, operations, and release checklist.

## Environment Files

- `requirements.txt`: Primary Python dependency list.
- `pyproject.toml`: Package metadata and optional extras when available.
- `.env.example`: Template for local credentials or backend configuration.

## Smoke Checks

Run these checks before long jobs:

```bash
python -m compileall -q memloop
memloop doctor
pytest
python -m build
```

If no smoke command is tracked, use the README Quick Start with the smallest seed, sample, or task count.

## Runtime Entry Points

Main tracked entry points for local or benchmark-scale runs:

- `memloop build-hierarchy`
- `memloop run`
- `memloop evaluate`
- `bash scripts/launch_v6.sh`
- `bash scripts/rerun_evals.sh`
- `bash scripts/run_erag_query.sh`
- `bash scripts/run_erag_query_chain.sh`
- `bash scripts/run_erag_tier.sh`

## Figure Assets

- `assets/benchmark-construction.png`
- `assets/dual-memory.png`
- `assets/on-demand-promotion.png`
- `assets/path-search.png`
- `assets/retrieval-pipeline.png`

## Data And Outputs

- API-backed runs should read credentials from environment variables or local `.env` files only; never commit real keys or provider-specific secrets.
- Record provider endpoint, model/deployment name, sampling parameters, and execution date for every API-backed table or figure.
- Treat generated JSONL files, logs, caches, model checkpoints, and benchmark downloads as local artifacts unless explicitly tracked as fixtures.
- For stochastic experiments, record seeds, task counts, dataset splits, and the exact git commit used for the run.

## Reporting Checklist

- `git rev-parse HEAD`
- Python version and dependency-install command
- Full command line for every table, figure, or benchmark cell
- Paths to raw outputs and aggregation scripts
- External data, benchmark, or API-backed steps that were intentionally skipped
