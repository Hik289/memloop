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

TIER="${1:?usage: scripts/run_erag_tier.sh <tier> [l0_parquet] [out_dir]}"
L0_PARQUET="${2:-manifests/erag_${TIER}_l0_nodes.parquet}"
OUT_DIR="${3:-results/hierarchy/erag_${TIER}}"

mkdir -p "$OUT_DIR"
export PYTHONPATH="$ROOT:${PYTHONPATH:-}"
export MEMLOOP_EMBED_BACKEND="${MEMLOOP_EMBED_BACKEND:-minilm}"

python -u -m memloop.data.build_hierarchy_dynamic \
  --tier "$TIER" \
  --l0_parquet "$L0_PARQUET" \
  --out_dir "$OUT_DIR" \
  ${MEMLOOP_DRY_RUN:+--dry_run}
