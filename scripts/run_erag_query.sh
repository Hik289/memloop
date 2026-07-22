#!/usr/bin/env bash
set -euo pipefail

ROOT="${MEMLOOP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT"
export MEMLOOP_REPO_ROOT="$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

METHOD="${1:-V5}"
TIER="${2:-10M}"
HIERARCHY="${3:-results/hierarchy/erag_${TIER}/hierarchy.json}"
QUERIES="${4:-manifests/erag_queries.parquet}"
OUT="${5:-results/runs/erag_${TIER}/${METHOD}}"

mkdir -p "$OUT"
export PYTHONPATH="$ROOT:${PYTHONPATH:-}"
export MEMLOOP_EMBED_BACKEND="${MEMLOOP_EMBED_BACKEND:-minilm}"
export MEMLOOP_L0_RETRIEVAL="${MEMLOOP_L0_RETRIEVAL:-bm25}"
export MEMLOOP_SKIP_L0_EMBED="${MEMLOOP_SKIP_L0_EMBED:-1}"
export MEMLOOP_ANSWER_MODE="${MEMLOOP_ANSWER_MODE:-detailed_truncated}"

python -u -m memloop.runners.run_stream_v5 \
  --method "$METHOD" \
  --hierarchy "$HIERARCHY" \
  --queries "$QUERIES" \
  --alias_answer "${MEMLOOP_ALIAS_ANSWER:-general}" \
  --alias_navigator "${MEMLOOP_ALIAS_NAVIGATOR:-general}" \
  --alias_low "${MEMLOOP_ALIAS_LOW:-general}" \
  --top_k_distilled "${MEMLOOP_TOP_K_DISTILLED:-25}" \
  --max_detailed_load "${MEMLOOP_MAX_DETAILED_LOAD:-10}" \
  --out "$OUT" \
  --resume
