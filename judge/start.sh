#!/usr/bin/env bash
set -euo pipefail

# judge/start.sh
#
# Workflow:
#  1) random 3-5 problems
#  2) generate tests (problems/<id>/tests/*.in)
#  3) generate expected outputs (problems/<id>/tests/*.out)
#  4) copy buggy.cpp -> workspace/<id>/main.cpp
#  5) create state/round.json

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBLEMS_DIR="$ROOT/problems"
WORKSPACE_DIR="$ROOT/workspace"
STATE_DIR="$ROOT/state"
HISTORY_DIR="$ROOT/history"

export PROBLEMS_DIR
export WORKSPACE_DIR

COUNT=""
TESTS=20

while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)
      COUNT="$2"; shift 2;;
    --tests)
      TESTS="$2"; shift 2;;
    *)
      echo "Usage: ./judge/start.sh [--count 1..5] [--tests N]" >&2
      exit 2;;
  esac
done

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

mkdir -p "$WORKSPACE_DIR" "$STATE_DIR" "$HISTORY_DIR"

# Clean artifacts from previous rounds
"$ROOT/judge/clean.sh" >/dev/null || true

# Select random problems
export COUNT

SELECTED_JSON="$($PYTHON_BIN "${PYTHON_ARGS[@]}" - <<'PY'
import json, os, random, sys

problems_dir = os.environ.get('PROBLEMS_DIR')
count_s = os.environ.get('COUNT', '')

ids = []
for name in sorted(os.listdir(problems_dir)):
    p = os.path.join(problems_dir, name)
    if os.path.isdir(p):
        buggy = os.path.join(p, 'buggy.cpp')
        sol = os.path.join(p, 'sol.cpp')
        gentest = os.path.join(p, 'gentest.cpp')
        try:
            if not (os.path.isfile(buggy) and os.path.getsize(buggy) > 0):
                continue
            if not (os.path.isfile(sol) and os.path.getsize(sol) > 0):
                continue
            if not (os.path.isfile(gentest) and os.path.getsize(gentest) > 0):
                continue
        except OSError:
            continue
        ids.append(name)

if not ids:
    print(json.dumps([]))
    sys.exit(0)

if count_s.strip() == '':
    # Default: try for 3-5, but if fewer valid problems exist, just take what's available.
    if len(ids) >= 3:
        k = random.randint(3, min(5, len(ids)))
    else:
        k = len(ids)
else:
    k = int(count_s)
    if k < 1 or k > 5:
        raise SystemExit('count must be 1..5')

k = min(k, len(ids))
selected = random.sample(ids, k)
print(json.dumps(selected))
PY
)"

if [[ "$SELECTED_JSON" == "[]" ]]; then
  echo "No problems found in problems/" >&2
  exit 1
fi

# Clear previous round state
rm -f "$STATE_DIR/round.json"

# Generate tests + expected outputs, then copy buggy into workspace
export SELECTED_JSON
SELECTED_IDS="$($PYTHON_BIN "${PYTHON_ARGS[@]}" - <<'PY'
import json, os
arr = json.loads(os.environ['SELECTED_JSON'])
print("\n".join(arr))
PY
)"

idx=0
while IFS= read -r pid; do
  idx=$((idx+1))
  "$ROOT/judge/gen_tests.sh" "$pid" --tests "$TESTS"

  # Copy buggy code into a flat workspace file, but prefix the statement as comments.
  # This keeps the UX: open workspace/<id>.cpp and you see the problem statement first.
  export PID="$pid"
  "$PYTHON_BIN" "${PYTHON_ARGS[@]}" - <<'PY'
import os
from pathlib import Path

problems_dir = Path(os.environ["PROBLEMS_DIR"])
workspace_dir = Path(os.environ["WORKSPACE_DIR"])
pid = os.environ["PID"]

stmt_path = problems_dir / pid / "statement.txt"
buggy_path = problems_dir / pid / "buggy.cpp"
out_path = workspace_dir / f"{pid}.cpp"
tmp_path = out_path.with_suffix(out_path.suffix + ".tmp")

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""

statement = read_text(stmt_path).rstrip("\n")
buggy = read_text(buggy_path)

parts: list[str] = []
if statement.strip():
    parts.append(f"// ===== STATEMENT ({pid}) =====\n")
    for line in statement.splitlines():
        parts.append("// " + line + "\n")
    parts.append("// ===== END STATEMENT =====\n\n")

parts.append(buggy)

tmp_path.write_text("".join(parts), encoding="utf-8", errors="replace")
os.replace(tmp_path, out_path)
PY
done <<< "$SELECTED_IDS"

# Create round.json
ROUND_PATH="$STATE_DIR/round.json"
export ROUND_PATH
export WORKSPACE_DIR
export SELECTED_JSON

$PYTHON_BIN "${PYTHON_ARGS[@]}" - <<'PY'
import json, os, time

round_path = os.environ['ROUND_PATH']
selected = json.loads(os.environ['SELECTED_JSON'])

data = {
  "start_time": int(time.time()),
  "current_problem": 0,
  "problems": [
    {"id": pid, "status": "pending", "start_time": None, "finish_time": None}
    for pid in selected
  ]
}

with open(round_path, 'w', encoding='utf-8') as f:
  json.dump(data, f, ensure_ascii=False, indent=2)
PY

echo "Round started. Problems:"
echo "$SELECTED_IDS" | sed 's/^/  - /'
echo
echo "Commands:"
echo "  ./judge/open.sh"
echo "  ./judge/submit.sh"
echo "  ./judge/next.sh"
