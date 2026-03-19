#!/usr/bin/env bash
set -euo pipefail

# judge/open.sh <problemId>
# Opens <repo_root>/<id>.cpp (stateless: no round tracking)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PID="${1:-}"
if [[ -z "$PID" ]]; then
  echo "Usage: ./judge/open.sh <problemId>  (e.g. p1)" >&2
  exit 2
fi

if [[ ! "$PID" =~ ^[pP]([0-9]{1,3})$ ]]; then
  echo "Invalid problem id: $PID" >&2
  exit 2
fi

N="${BASH_REMATCH[1]}"
SHORT_PID="p$((10#$N))"

FILE="$ROOT/$SHORT_PID.cpp"
if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  echo "(Did you run ./judge/start.sh?)" >&2
  exit 1
fi

if command -v code >/dev/null 2>&1; then
  code "$FILE"
else
  echo "Open this file: $FILE"
fi
