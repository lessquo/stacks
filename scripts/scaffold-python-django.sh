#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# UV_PROJECT_ENVIRONMENT keeps the .venv off the bind mount, so only pyproject.toml
# + uv.lock land on the host. The package is `config` (`python-django` is not a
# valid module name).
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
