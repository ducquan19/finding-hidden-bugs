#!/usr/bin/env bash
set -euo pipefail

# judge/clean.sh
# Clean artifacts so you can start fresh.
# - Removes generated root-level p*.cpp files (those created by start.sh)
# - Removes build/judge/
# - Removes legacy state/ and history/ folders (if present)

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT/build/judge"
LEGACY_STATE_DIR="$ROOT/state"
LEGACY_HISTORY_DIR="$ROOT/history"

# Remove only files that look like judge-generated round files.
shopt -s nullglob
for f in "$ROOT"/p*.cpp; do
	if [[ -f "$f" ]] && grep -q "^// ===== STATEMENT (p" "$f"; then
		rm -f "$f" 2>/dev/null || true
	fi
done

rm -rf "$BUILD_DIR" 2>/dev/null || true

# Legacy cleanup (repo no longer uses these)
rm -rf "$LEGACY_STATE_DIR" 2>/dev/null || true
rm -rf "$LEGACY_HISTORY_DIR" 2>/dev/null || true

echo "Cleaned: generated p*.cpp, build/judge/, (legacy) state/, history/"
