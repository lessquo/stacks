# schemathesis

Spec-driven conformance testing with [Schemathesis](https://schemathesis.io). It reads [`spec/openapi.yaml`](../../spec/openapi.yaml) as the source of truth, generates property-based requests from it, and checks the live backend's responses against the schema — so the assertions *are* the contract, with nothing hand-written to drift from it.

## Running

Start a backend (publishes port 8080), then from the repo root:

```bash
make conformance-schemathesis                                   # default BASE_URL
make conformance-schemathesis BASE_URL=http://host.docker.internal:8080
```

Runs the official `schemathesis/schemathesis` image (pinned `4.20.3`) — nothing installed on the host. The spec is mounted read-only; the backend is reached over `BASE_URL`.

## Notes

- **Spec version:** Schemathesis loads our OpenAPI **3.2.0** spec without issue.
- **Stateful flows:** it auto-infers the create→retrieve link (`POST /users` returns `id`, `GET /users/{id}` consumes it) — no manual OpenAPI `links` needed.
- **Auth (future):** when the contract gains authentication, a `schemathesis.toml` here can declare the token endpoint (dynamic auth) so tokens are fetched and injected automatically — roughly four lines, no custom code.
