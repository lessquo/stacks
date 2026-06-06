# python-fastapi

Python + FastAPI implementation of the shared `stacks` API. The contract it implements lives in [`spec/openapi.yaml`](../../spec/openapi.yaml).

## Stack

- Python 3.14, FastAPI on uvicorn (ASGI, `async def` endpoints)
- PostgreSQL 18 via SQLAlchemy 2.0 (async) + the asyncpg driver
- Alembic for migrations
- uv for dependency management
- Container-first: Docker Compose for everything; nothing is installed on the host.

## Running

All targets live in the repo-root `Makefile`; run them from the repo root:

```bash
make python-fastapi-migrate   # start Postgres + apply migrations (one-shot), then exits
make python-fastapi           # start the app with hot reload → http://localhost:8080
```

## Migrations

Manual (not auto-run on boot). Alembic migration files live in [`alembic/versions/`](alembic/versions/). Autogenerate diffs the SQLAlchemy models in [`models.py`](models.py) against the live schema — review the generated file before applying it.

```bash
make python-fastapi-revision name=<slug>   # autogenerate a migration from model changes
make python-fastapi-migrate                # apply pending migrations (alembic upgrade head)
```

Alembic reads the DB URL from [`db.py`](db.py) (built from `DB_*` env vars) via [`alembic/env.py`](alembic/env.py), not from `alembic.ini` — so app and migrations always share one connection definition.

## Implementation choices

Stack-local detail not captured by [comparison.md](../../comparison.md), which has the cross-stack mechanics (ids, timestamps, validation, errors, routing):

- **Async-first:** `async def` endpoints on uvicorn, async SQLAlchemy 2.0 (`Mapped[...]` / `mapped_column`) + asyncpg, a per-request `AsyncSession` injected with `Depends`.
- **Single-statement create:** SQLAlchemy's `eager_defaults="auto"` appends the server-generated columns to the insert's `RETURNING`, so create is one `INSERT … RETURNING` round-trip — no follow-up `SELECT`.
- **Wire vs DB types:** Pydantic `CreateUser` / `UserResponse` schemas decoupled from the ORM model; camelCase output (`createdAt`) comes from a serialization-only alias, so `from_attributes` still reads the snake_case ORM attributes.
- **Validation gotcha:** an `email-validator`-backed annotated type validates but **returns the client's original string** — `EmailStr` would normalize the address (e.g. punycode → Unicode) and break the contract's `format: email` (caught by conformance).
- **Overriding FastAPI's `422`:** FastAPI defaults to `422` for both invalid bodies and malformed path UUIDs; handlers in [`problem.py`](problem.py) remap these to `400` (validation) and `404` (malformed id) to match the contract.

## Dev environment

- Runs entirely in containers. Compose Watch syncs the source; uvicorn's `--reload` restarts the app process on change (the in-process analogue to Django's `runserver` reloader).
- Dependencies are managed with uv; the `.venv` is built into the image (`uv sync --frozen`) and never lives on the host.
- The app reads `PORT` (defaults to 8080) and `DB_*` env.
