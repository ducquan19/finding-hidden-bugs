#!/usr/bin/env bash
set -euo pipefail

# judge/start.sh
#
# Stateless workflow:
#  1) random 3-5 problems
#  2) generate tests (problems/<id>/tests/*.in)
#  3) generate expected outputs (problems/<id>/tests/*.out)
#  4) copy buggy.cpp -> <repo_root>/p1.cpp, p2.cpp, ... (slot ids)
#
# Note: this script does NOT create state/round.json or history files.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROBLEMS_DIR="$ROOT/problems"
BACKUP_ROOT="$ROOT/build/_backups"
MAP_FILE="$ROOT/build/judge/round_map.json"

export PROBLEMS_DIR
export BACKUP_ROOT

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

# Generate tests + expected outputs (skips if already exist), then copy buggy into repo root
export SELECTED_JSON
SELECTED_IDS="$($PYTHON_BIN "${PYTHON_ARGS[@]}" - <<'PY'
import json, os
arr = json.loads(os.environ['SELECTED_JSON'])
print("\n".join(arr))
PY
)"

mkdir -p "$(dirname "$MAP_FILE")"

echo "{" > "$MAP_FILE"
first_map=1

idx=0
loaded_slots=()
while IFS= read -r pid; do
  idx=$((idx+1))
  slot="p$idx"
  loaded_slots+=("$slot")

  if [[ "$first_map" -eq 0 ]]; then
    printf ",\n" >> "$MAP_FILE"
  fi
  printf "  \"%s\": \"%s\"" "$slot" "$pid" >> "$MAP_FILE"
  first_map=0

  "$ROOT/judge/gen_tests.sh" "$pid" --tests "$TESTS"

  # Copy buggy code into a flat repo-root file (p1.cpp, p2.cpp, ...),
  # and prefix the statement as comments.
  export PID="$pid"
  export SLOT_PID="$slot"
  "$PYTHON_BIN" "${PYTHON_ARGS[@]}" - <<'PY'
import os
from pathlib import Path
from datetime import datetime

problems_dir = Path(os.environ["PROBLEMS_DIR"])
backup_root = Path(os.environ.get("BACKUP_ROOT", ""))
pid = os.environ["PID"]
slot_pid = os.environ.get("SLOT_PID", "")

if not slot_pid:
    raise SystemExit("missing SLOT_PID")

stmt_path = problems_dir / pid / "statement.txt"
buggy_path = problems_dir / pid / "buggy.cpp"
out_path = Path(os.getcwd()) / f"{slot_pid}.cpp"
tmp_path = out_path.with_suffix(out_path.suffix + ".tmp")

# Backup any existing non-generated file so we don't lose user work.
marker = f"// ===== STATEMENT ({slot_pid}) ====="
if out_path.exists():
    try:
        head = out_path.read_text(encoding="utf-8", errors="replace")[:200]
    except Exception:
        head = ""

    if marker not in head and str(backup_root):
      try:
        backup_root.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d-%H%M%S")
        backup_path = backup_root / f"{slot_pid}.cpp.{ts}.bak"
        backup_path.write_bytes(out_path.read_bytes())
      except Exception:
        pass

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""

statement = read_text(stmt_path).rstrip("\n")
buggy = read_text(buggy_path)

parts: list[str] = []
if statement.strip():
    parts.append(f"// ===== STATEMENT ({slot_pid}) =====\n")
    for line in statement.splitlines():
        parts.append("// " + line + "\n")
    parts.append("// ===== END STATEMENT =====\n\n")

parts.append(buggy)

tmp_path.write_text("".join(parts), encoding="utf-8", errors="replace")
os.replace(tmp_path, out_path)
PY
done <<< "$SELECTED_IDS"

printf "\n}\n" >> "$MAP_FILE"

echo "Problems loaded into repo root:"
for s in "${loaded_slots[@]}"; do
  echo "  - $s"
done
echo
echo "Commands:"
echo "  ./judge/open.sh p1"
echo "  ./judge/submit.sh p1"
