#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo root from this script's location so it works from any CWD.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# Scaffold without installing (no host node_modules), then write only the
# lockfile — the Docker image runs `npm ci`, which needs package-lock.json.
docker run --rm -it \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  node:24-alpine \
  sh -c "npx -y @nestjs/cli new ts-nestjs --skip-git --skip-install --strict --package-manager npm \
         && cd ts-nestjs \
         && npm install --package-lock-only"
