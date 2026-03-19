#!/usr/bin/env bash
set -euo pipefail

# judge/gen_all_tests.sh [--tests N] [--seed S] [--force]
# Regenerate tests for all problems under problems/p*/ that have gentest.cpp + sol.cpp.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBLEMS_DIR="$ROOT/problems"

NUM_TESTS=20
BASE_SEED=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tests)
      NUM_TESTS="$2"; shift 2;;
    --seed)
      BASE_SEED="$2"; shift 2;;
    --force)
      FORCE=1; shift 1;;
    *)
      echo "Usage: ./judge/gen_all_tests.sh [--tests N] [--seed S] [--force]" >&2
      exit 2;;
  esac
done

if [[ -z "$BASE_SEED" ]]; then
  BASE_SEED="$(date +%s)"
fi

shopt -s nullglob
pdirs=("$PROBLEMS_DIR"/p*/)
if [[ ${#pdirs[@]} -eq 0 ]]; then
  echo "No problems found under problems/p*/" >&2
  exit 1
fi

ok=0
skip=0
fail=0
idx=0

for d in "${pdirs[@]}"; do
  pid="$(basename "$d")"
  gentest="$d/gentest.cpp"
  sol="$d/sol.cpp"

  if [[ ! -f "$gentest" || ! -f "$sol" ]]; then
    skip=$((skip+1))
    continue
  fi

  idx=$((idx+1))
  seed="$((BASE_SEED + idx))"

  echo "==> $pid (tests=$NUM_TESTS, seed=$seed)"
  args=("$pid" --tests "$NUM_TESTS" --seed "$seed")
  if [[ "$FORCE" -eq 1 ]]; then
    args+=(--force)
  fi
  if "$ROOT/judge/gen_tests.sh" "${args[@]}"; then
    ok=$((ok+1))
  else
    fail=$((fail+1))
  fi
  echo

done

echo "Done. ok=$ok, failed=$fail, skipped=$skip"

if [[ $fail -ne 0 ]]; then
  exit 1
fi
