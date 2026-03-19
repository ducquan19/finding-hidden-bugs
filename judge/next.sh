#!/usr/bin/env bash
set -euo pipefail

# judge/next.sh
# Stateless mode: there is no tracked round/pending list.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "No tracked round in stateless mode."
echo "Use: ./judge/open.sh <problemId>  (e.g. ./judge/open.sh p01)"
