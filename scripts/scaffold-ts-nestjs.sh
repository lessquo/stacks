#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# Skip install; write only the lockfile the Docker image's `npm ci` needs.
docker run --rm -it \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  node:24-alpine \
  sh -c "npx -y @nestjs/cli new ts-nestjs --skip-git --skip-install --strict --package-manager npm \
         && cd ts-nestjs \
         && npm install --package-lock-only"
