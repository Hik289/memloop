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

MODE="${1:-smoke}"
N=50
if [[ "$MODE" == "full" ]]; then
  N=500
fi

export PYTHONPATH="$ROOT:${PYTHONPATH:-}"
export MEMLOOP_L0_RETRIEVAL="${MEMLOOP_L0_RETRIEVAL:-bm25}"
export MEMLOOP_EMBED_BACKEND="${MEMLOOP_EMBED_BACKEND:-minilm}"
export MEMLOOP_SKIP_L0_EMBED="${MEMLOOP_SKIP_L0_EMBED:-1}"
export MEMLOOP_V6_DUAL_MEM=1

HIERARCHY="${MEMLOOP_HIERARCHY:-results/hierarchy/erag_10M/hierarchy.json}"
QUERIES="${MEMLOOP_QUERIES:-manifests/erag_queries.parquet}"
OUT="${MEMLOOP_OUT:-results/runs/erag_10M/V5_v6_dual_mem}"

python -u -m memloop.runners.run_stream_v5 \
  --method V5 \
  --hierarchy "$HIERARCHY" \
  --queries "$QUERIES" \
  --alias_answer "${MEMLOOP_ALIAS_ANSWER:-general}" \
  --alias_navigator "${MEMLOOP_ALIAS_NAVIGATOR:-general}" \
  --alias_low "${MEMLOOP_ALIAS_LOW:-general}" \
  --top_k_distilled "${MEMLOOP_TOP_K_DISTILLED:-25}" \
  --max_detailed_load "${MEMLOOP_MAX_DETAILED_LOAD:-10}" \
  --n_smoke "$N" \
  --out "$OUT" \
  --resume
