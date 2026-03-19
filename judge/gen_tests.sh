#!/usr/bin/env bash
set -euo pipefail

# judge/gen_tests.sh <problemId> [--tests N] [--seed S]
#
# Logic:
#   compile gentest.cpp
#   generate tests/*.in into problems/<id>/tests
#   compile sol.cpp
#   generate tests/*.out (expected outputs)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBLEMS_DIR="$ROOT/problems"
BUILD_ROOT="$ROOT/build/judge"

if [[ $# -lt 1 ]]; then
  echo "Usage: ./judge/gen_tests.sh <problemId> [--tests N] [--seed S]" >&2
  exit 2
fi

PID="$1"; shift
NUM_TESTS=20
SEED=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tests)
      NUM_TESTS="$2"; shift 2;;
    --seed)
      SEED="$2"; shift 2;;
    --force)
      FORCE=1; shift 1;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2;;
  esac
done

P_DIR="$PROBLEMS_DIR/$PID"
if [[ ! -d "$P_DIR" ]]; then
  echo "Problem not found: $PID" >&2
  exit 1
fi

if [[ -z "$SEED" ]]; then
  SEED="$(date +%s)"
fi

TESTS_DIR="$P_DIR/tests"
BUILD_DIR="$BUILD_ROOT/$PID"
GENTEST_SRC="$P_DIR/gentest.cpp"
SOL_SRC="$P_DIR/sol.cpp"

mkdir -p "$TESTS_DIR" "$BUILD_DIR"

shopt -s nullglob
ins=("$TESTS_DIR"/*.in)
outs=("$TESTS_DIR"/*.out)

if [[ "$FORCE" -eq 0 ]]; then
  if [[ ${#ins[@]} -gt 0 && ${#outs[@]} -gt 0 ]]; then
    echo "Tests already exist for $PID (in=${#ins[@]}, out=${#outs[@]}). Skipping."
    exit 0
  fi
  if [[ ${#ins[@]} -gt 0 && ${#outs[@]} -eq 0 ]]; then
    # Inputs exist; only generate expected outputs.
    SOL_EXE="$BUILD_DIR/sol.exe"
    g++ -std=c++17 -O2 -pipe -s "$SOL_SRC" -o "$SOL_EXE"
    for in_file in "${ins[@]}"; do
      out_file="${in_file%.in}.out"
      "$SOL_EXE" < "$in_file" > "$out_file"
    done
    echo "Generated ${#ins[@]} expected output(s) for $PID"
    exit 0
  fi
fi

# Clean existing tests (force regen or missing/partial tests)
rm -f "$TESTS_DIR"/*.in "$TESTS_DIR"/*.out 2>/dev/null || true

GENTEST_EXE="$BUILD_DIR/gentest.exe"
SOL_EXE="$BUILD_DIR/sol.exe"

if [[ ! -f "$GENTEST_SRC" ]]; then
  echo "Missing gentest.cpp for $PID" >&2
  exit 1
fi
if [[ ! -f "$SOL_SRC" ]]; then
  echo "Missing sol.cpp for $PID" >&2
  exit 1
fi

g++ -std=c++17 -O2 -pipe -s "$GENTEST_SRC" -o "$GENTEST_EXE"
"$GENTEST_EXE" "$TESTS_DIR" "$SEED" "$NUM_TESTS"

# Generate expected outputs
IN_COUNT=0
for in_file in "$TESTS_DIR"/*.in; do
  if [[ ! -f "$in_file" ]]; then
    continue
  fi
  IN_COUNT=$((IN_COUNT+1))
done

if [[ "$IN_COUNT" -eq 0 ]]; then
  echo "gentest produced no .in files for $PID" >&2
  exit 1
fi

g++ -std=c++17 -O2 -pipe -s "$SOL_SRC" -o "$SOL_EXE"

for in_file in "$TESTS_DIR"/*.in; do
  out_file="${in_file%.in}.out"
  "$SOL_EXE" < "$in_file" > "$out_file"
done

echo "Generated $IN_COUNT tests for $PID"
