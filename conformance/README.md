# conformance

Ways to verify that a backend satisfies the shared contract in [`spec/openapi.yaml`](../spec/openapi.yaml).

Each subfolder is **one testing approach/tool** — just as each `backends/<stack>/` is one *implementation* of the contract, each `conformance/<tool>/` is one *way to check* it. They're all black-box: they speak only HTTP and read the spec, so the same suite runs against any backend.

## How it works

1. Start any backend (it publishes the API on port **8080**):
   ```bash
   make python-django        # or any other stack
   ```
2. In another terminal, run a conformance tool against it:
   ```bash
   make conformance-schemathesis
   ```

The target points at `BASE_URL` (default `http://host.docker.internal:8080`, i.e. the host's published port as seen from inside the tool's container). Override it for a different host/port:

```bash
make conformance-schemathesis BASE_URL=http://host.docker.internal:9090
```

## Approaches

| Folder | Tool | Style |
|---|---|---|
| [`schemathesis/`](schemathesis/) | [Schemathesis](https://schemathesis.io) | spec-driven — derives tests from `openapi.yaml`, property-based |

More can be added later (e.g. a hand-written declarative suite with [Hurl](https://hurl.dev)) to learn and compare approaches — same contract, different verification strategy.
