#!/usr/bin/env bash
set -euo pipefail

# Scaffold the TS + NestJS backend into backends/ts-nestjs using a throwaway
# Docker container, so no NestJS CLI, npm, or Node is installed on the host.
#
# Usage:  ./scripts/scaffold-ts-nestjs.sh
# Requires: Docker.

# Resolve the repo root from this script's location (works from any CWD).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

docker run --rm -it \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  node:24 \
  npx -y @nestjs/cli new ts-nestjs --skip-git --strict --package-manager npm
