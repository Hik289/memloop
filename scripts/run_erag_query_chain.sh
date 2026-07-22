#!/usr/bin/env bash
set -euo pipefail

TIER="${1:-10M}"
ROOT="${MEMLOOP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export MEMLOOP_REPO_ROOT="$ROOT"

for METHOD in B_flat B_fixed_hier B_dynamic_hier B_llm_nav V5; do
  bash "$ROOT/scripts/run_erag_query.sh" "$METHOD" "$TIER"
done
