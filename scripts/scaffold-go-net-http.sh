#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# Scaffold in a throwaway container so the Go toolchain never touches the host.
docker run --rm -it \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  golang:1.26-alpine \
  sh -c "mkdir go-net-http \
         && cd go-net-http \
         && go mod init github.com/lessquo/stacks/go-net-http"
