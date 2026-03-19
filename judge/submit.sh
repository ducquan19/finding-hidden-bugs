#!/usr/bin/env bash
set -euo pipefail

# judge/submit.sh <problemId>
# Stateless checker:
#   - compile <repo_root>/<id>.cpp
#   - run all problems/<id>/tests/*.in
#   - compare output to problems/<id>/tests/*.out (byte-for-byte)
# Prints one of:
#   ACCEPTED, WRONG ANSWER, COMPILE ERROR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBLEMS_DIR="$ROOT/problems"
BUILD_ROOT="$ROOT/build/judge"
MAP_FILE="$BUILD_ROOT/round_map.json"

PID="${1:-}"
if [[ -z "$PID" ]]; then
  echo "Usage: ./judge/submit.sh <problemId>  (e.g. ./judge/submit.sh p1)" >&2
  exit 2
fi

if [[ ! "$PID" =~ ^[pP]([0-9]{1,3})$ ]]; then
  echo "Invalid problem id: $PID" >&2
  exit 2
fi

N="${BASH_REMATCH[1]}"
NUM=$((10#$N))
PID_SHORT="p$NUM"

PYTHON_BIN=""
PYTHON_ARGS=()
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=python3
elif command -v py >/dev/null 2>&1; then
  PYTHON_BIN=py
  PYTHON_ARGS=(-3)
else
  PYTHON_BIN=python
fi

# Default mapping: p1 -> problems/p01, etc.
PID_NORM=$(printf 'p%02d' "$NUM")

# Round mapping: if round_map.json exists and contains PID_SHORT,
# use that as the actual problem id for tests/build folders.
if [[ -f "$MAP_FILE" ]]; then
  RESOLVED="$(MAP_FILE="$MAP_FILE" PID_SHORT="$PID_SHORT" \
    "$PYTHON_BIN" "${PYTHON_ARGS[@]}" - <<'PY'
import json, os
from pathlib import Path

mp = Path(os.environ["MAP_FILE"])
key = os.environ["PID_SHORT"].lower()
try:
    data = json.loads(mp.read_text(encoding="utf-8"))
except Exception:
    data = {}

val = data.get(key)
if isinstance(val, str) and val.strip():
    print(val.strip())
PY
  )"
  if [[ -n "$RESOLVED" ]]; then
    PID_NORM="$RESOLVED"
  fi
fi

SRC="$ROOT/$PID_SHORT.cpp"
if [[ ! -f "$SRC" ]]; then
  echo "File not found: $SRC" >&2
  exit 1
fi

TESTS_DIR="$PROBLEMS_DIR/$PID_NORM/tests"
if [[ ! -d "$TESTS_DIR" ]]; then
  echo "Tests not found: $TESTS_DIR" >&2
  echo "Run: ./judge/gen_tests.sh $PID_NORM" >&2
  exit 1
fi

BUILD_DIR="$BUILD_ROOT/$PID_NORM"
RUN_DIR="$BUILD_DIR/run"
mkdir -p "$BUILD_DIR" "$RUN_DIR"

EXE="$BUILD_DIR/submission.exe"

set +e
COMPILE_OUT=$(g++ -std=c++17 -O2 -pipe -s "$SRC" -o "$EXE" 2>&1)
RC=$?
set -e

if [[ $RC -ne 0 ]]; then
  echo "COMPILE ERROR"
  echo "$COMPILE_OUT"
  exit 0
fi

FIRST_WRONG=""
TOTAL=0

for in_file in "$TESTS_DIR"/*.in; do
  if [[ ! -f "$in_file" ]]; then
    continue
  fi
  TOTAL=$((TOTAL+1))
  base="$(basename "$in_file" .in)"
  expected="$TESTS_DIR/$base.out"
  actual="$RUN_DIR/$base.out"

  set +e
  "$EXE" < "$in_file" > "$actual"
  RUN_RC=$?
  set -e

  if [[ $RUN_RC -ne 0 ]]; then
    FIRST_WRONG="$(basename "$in_file") (runtime error)"
    break
  fi

  OK="$(EXPECTED="$expected" ACTUAL="$actual" $PYTHON_BIN "${PYTHON_ARGS[@]}" - <<'PY'
import os, sys
exp=os.environ['EXPECTED']
act=os.environ['ACTUAL']
try:
  eb=open(exp,'rb').read()
  ab=open(act,'rb').read()
  sys.stdout.write('1' if eb==ab else '0')
except FileNotFoundError:
  sys.stdout.write('0')
PY
)"

  if [[ "$OK" != "1" ]]; then
    FIRST_WRONG="$(basename "$in_file")"
    break
  fi
done

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No .in tests found in $TESTS_DIR" >&2
  exit 1
fi

if [[ -z "$FIRST_WRONG" ]]; then
  echo "ACCEPTED"
else
  echo "WRONG ANSWER - first failing test: $FIRST_WRONG"
fi
