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

Internal, idiomatic-to-this-stack decisions. The shared contract stays implementation-neutral — on the wire these are just a `uuid` string and an ISO-8601 `date-time` string.

- **Async-first:** `async def` endpoints on uvicorn, the async SQLAlchemy engine + asyncpg, a per-request `AsyncSession` injected with `Depends`.
- **ORM:** SQLAlchemy 2.0 declarative models (`Mapped[...]` / `mapped_column`), the third distinct data layer in the repo (vs Django ORM and Go's no-ORM sqlc).
- **IDs:** UUIDv7 via Postgres-native `uuidv7()` (Postgres 18), DB-generated through `server_default` — time-ordered.
- **Timestamps:** `timestamptz` (`DateTime(timezone=True)`) with DB defaults (`now()`), serialized as ISO-8601 by Pydantic.
- **Single-statement create:** SQLAlchemy's `eager_defaults="auto"` appends the server-generated columns to the insert's `RETURNING`, so create is one `INSERT … RETURNING id, created_at, updated_at` round-trip — no follow-up `SELECT`.
- **Wire vs DB types:** Pydantic `CreateUser` / `UserResponse` schemas decoupled from the ORM model; camelCase output (`createdAt`) comes from a serialization-only alias, so `from_attributes` still reads the snake_case ORM attributes.
- **Validation:** an `email-validator`-backed annotated type that validates but **returns the client's original string** — `EmailStr` would normalize the address (e.g. punycode → Unicode) and break the contract's `format: email` (caught by conformance).
- **Duplicate email → `409`:** catch SQLAlchemy `IntegrityError`, check `exc.orig.sqlstate == "23505"`.
- **Malformed id → `404`:** the path param is a `str` parsed with `UUID(...)`; a `ValueError` is treated as not-found (FastAPI's default would be `422`).
- **Validation → `400`:** a `RequestValidationError` handler overrides FastAPI's default `422`.
- **Errors:** RFC 9457 `application/problem+json` (`{ status, title, detail }`) via exception handlers in [`problem.py`](problem.py).

## Dev environment

- Runs entirely in containers. Compose Watch syncs the source; uvicorn's `--reload` restarts the app process on change (the in-process analogue to Django's `runserver` reloader).
- Dependencies are managed with uv; the `.venv` is built into the image (`uv sync --frozen`) and never lives on the host.
- The app reads `PORT` (defaults to 8080) and `DB_*` env.
