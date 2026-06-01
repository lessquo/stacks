# conformance

Ways to verify that a backend satisfies the shared contract in [`spec/openapi.yaml`](../spec/openapi.yaml).

Each subfolder is **one testing approach/tool** — just as each `backends/<stack>/` is one *implementation* of the contract, each `conformance/<tool>/` is one *way to check* it. They're all black-box: they speak only HTTP and read the spec, so the same suite runs against any backend.

## Running it

One command per stack brings up a **throwaway, isolated stack** (its own Compose project, so a fresh Postgres in a volume that's deleted on exit — your dev DB is never touched), applies migrations, runs Schemathesis against it over the Compose network, then tears it all down:

```bash
make conformance-python-django   # or conformance-ts-nestjs
```

This is orchestrated by [`schemathesis/run.sh`](schemathesis/run.sh); [`compose.no-ports.yaml`](compose.no-ports.yaml) overlays each stack's `compose.yaml` to drop host port publishing so the run can't collide with a dev stack.

## Approaches

| Folder | Tool | Style |
|---|---|---|
| [`schemathesis/`](schemathesis/) | [Schemathesis](https://schemathesis.io) | spec-driven — derives tests from `openapi.yaml`, property-based |
