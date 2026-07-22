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

ANSWERS="${1:?usage: scripts/rerun_evals.sh <answers.jsonl> <gold.jsonl> <out_dir>}"
GOLD="${2:?usage: scripts/rerun_evals.sh <answers.jsonl> <gold.jsonl> <out_dir>}"
OUT="${3:?usage: scripts/rerun_evals.sh <answers.jsonl> <gold.jsonl> <out_dir>}"

export PYTHONPATH="$ROOT:${PYTHONPATH:-}"
python -u -m memloop.eval.evaluate_v5 \
  --answers "$ANSWERS" \
  --gold "$GOLD" \
  --out "$OUT" \
  --resume
