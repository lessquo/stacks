#!/usr/bin/env sh
# Run Schemathesis against a backend in a throwaway, fully isolated Compose project.
#
# Usage: conformance/schemathesis/run.sh <stack> <migrate-command>
#   <stack>            directory name under backends/ (e.g. python-django)
#   <migrate-command>  command, run inside the app container, that creates the schema
#
# A dedicated project name (-p <stack>-conformance) namespaces the network and the
# database volume, so every run gets a brand-new Postgres that is removed on exit
# (down -v) — the dev stack's volume is never touched.
set -eu

stack="$1"
migrate="$2"

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"

compose="backends/$stack/compose.yaml"
override="conformance/compose.no-ports.yaml"
project="$stack-conformance"

compose_project() {
  docker compose -f "$compose" -f "$override" -p "$project" "$@"
}

# Always tear the throwaway stack (and its volume) down, pass or fail.
cleanup() {
  compose_project down -v
}
trap cleanup EXIT

# Fresh stack; --wait blocks until the db and app healthchecks pass.
compose_project up -d --build --wait

# The DB starts empty, so create the schema before testing.
compose_project exec -T app sh -c "$migrate"

# Schemathesis joins the project network and hits the app directly.
docker run --rm --network "${project}_default" \
  -v "$root/spec":/spec \
  -v "$root/conformance/schemathesis/schemathesis.toml":/schemathesis.toml \
  schemathesis/schemathesis:4.20.3 \
  --config-file /schemathesis.toml run /spec/openapi.yaml --url http://app:8080
