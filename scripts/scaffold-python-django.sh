#!/usr/bin/env bash
set -euo pipefail

# Resolve the repo root from this script's location so it works from any CWD.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# Scaffold via uv inside a throwaway container. UV_PROJECT_ENVIRONMENT points the
# .venv at /tmp (off the bind mount) so only pyproject.toml + uv.lock land on the
# host — the Docker image recreates the env with `uv sync`. The project package is
# named `config` because `python-django` is not a valid Python module name.
docker run --rm -it \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  -e UV_PROJECT_ENVIRONMENT=/tmp/venv \
  python:3.14-slim \
  sh -c "pip install --quiet uv \
         && uv init --bare python-django \
         && cd python-django \
         && uv add django \
         && uv run django-admin startproject config ."
