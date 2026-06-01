# schemathesis

Spec-driven conformance testing with [Schemathesis](https://schemathesis.io). It reads [`spec/openapi.yaml`](../../spec/openapi.yaml) as the source of truth, generates property-based requests from it, and checks the live backend's responses against the schema — so the assertions *are* the contract, with nothing hand-written to drift from it.

## Running

From the repo root, one command per stack (see [`../README.md`](../README.md) for what it does — throwaway stack, fresh DB, automatic teardown):

```bash
make conformance-python-django   # or conformance-ts-nestjs
```

Runs the official `schemathesis/schemathesis` image (pinned `4.20.3`) — nothing installed on the host. The spec is mounted read-only; the backend is reached at `http://app:8080` over the Compose network.

## Notes

- **Spec version:** Schemathesis loads our OpenAPI **3.2.0** spec without issue.
- **Stateful flows:** it auto-infers the create→retrieve link (`POST /users` returns `id`, `GET /users/{id}` consumes it) — no manual OpenAPI `links` needed.
