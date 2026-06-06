# go-net-http

Go + standard-library `net/http` implementation of the shared `stacks` API. The contract it implements lives in [`spec/openapi.yaml`](../../spec/openapi.yaml).

## Stack

- Go 1.26, standard-library `net/http` (Go 1.22+ `ServeMux` routing — no web framework)
- PostgreSQL 18 via pgx v5 (`pgxpool`)
- sqlc for the type-safe query layer; goose for migrations
- Container-first: Docker Compose for everything; nothing is installed on the host.

## Running

All targets live in the repo-root `Makefile`; run them from the repo root:

```bash
make go-net-http-migrate   # start Postgres + apply migrations (one-shot), then exits
make go-net-http           # start the app with hot reload → http://localhost:8080
```

## Migrations

Manual (not auto-run on boot). Migration files are hand-written SQL in [`migrations/`](migrations/), embedded into the binary via `go:embed` and applied by goose through the binary's `migrate` subcommand. There is no generator — the SQL is hand-written (no ORM model to diff against), and `migrations/` doubles as the schema source of truth for sqlc.

```bash
make go-net-http-migrate   # apply pending migrations (runs `go run . migrate`)
```

## Queries

Hand-written SQL in [`queries/`](queries/) is compiled by sqlc into the type-safe Go package [`internal/db/`](internal/db/) (committed; regenerate with `make go-net-http-sqlc`).

## Implementation choices

Stack-local detail not captured by [comparison.md](../../comparison.md), which has the cross-stack mechanics (ids, timestamps, validation, errors, routing):

- **No framework, no ORM:** stdlib `net/http` for routing, sqlc-generated code over pgx for queries — every SQL statement is hand-written and visible (the deliberate contrast to the ORM stacks).
- **Routing:** Go 1.22+ `ServeMux` method+path patterns; the health route is anchored `GET /{$}`.
- **Type mapping:** sqlc overrides `uuid`→`google/uuid.UUID` and `timestamptz`→`time.Time` (clean because every column is `NOT NULL`), instead of pgx's nullable `pgtype.*` wrappers.
- **Wire vs DB types:** separate camelCase JSON structs (`userResponse`, `createUserRequest`) decoupled from the generated `db.User`, so the contract never leaks DB types and the generated code stays tag-free.

## Dev environment

- Runs entirely in containers. Compose Watch syncs the source and restarts the container (`sync+restart`); the dev image runs `go run .`, which recompiles on restart. No live-reload tool (e.g. `air`) yet — revisit if the restart loop becomes a drag.
- Single-stage `golang:1.26-alpine` image. The app reads `PORT` (defaults to 8080) and `DB_*` env.
