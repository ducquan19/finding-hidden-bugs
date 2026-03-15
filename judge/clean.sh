#!/usr/bin/env bash
set -euo pipefail

# judge/clean.sh
# Clean artifacts so you can start a new round.
# - Removes workspace/*.cpp
# - Removes state/round.json
# - Removes state/run/ and state/build/

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$ROOT/workspace"
STATE_DIR="$ROOT/state"

mkdir -p "$WORKSPACE_DIR" "$STATE_DIR"

rm -rf "$WORKSPACE_DIR"/* 2>/dev/null || true
rm -f "$STATE_DIR/round.json" 2>/dev/null || true
rm -rf "$STATE_DIR/run" 2>/dev/null || true
rm -rf "$STATE_DIR/build" 2>/dev/null || true

echo "Cleaned: workspace/, state/{round.json,run/,build/}"
