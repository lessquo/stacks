# python-django

Python + Django implementation of the shared `stacks` API. The contract it implements lives in [`spec/openapi.yaml`](../../spec/openapi.yaml).

## Stack

- Python 3.14, Django 6.0 + Django REST Framework
- PostgreSQL 18 via psycopg 3
- uv for dependency management
- Container-first: Docker Compose for everything; nothing is installed on the host.

## Running

All targets live in the repo-root `Makefile`; run them from the repo root:

```bash
make python-django-migrate   # start Postgres + apply migrations (one-shot), then exits
make python-django           # start the app with hot reload → http://localhost:8080
```

## Migrations

Manual (not auto-run on boot). Migration files live in `apps/<app>/migrations/`.

```bash
make python-django-makemigrations   # generate migrations from model changes (auto-named)
make python-django-migrate          # apply pending migrations
```

## Implementation choices

Internal, idiomatic-to-this-stack decisions. The shared contract stays implementation-neutral — on the wire these are just a `uuid` string and an ISO-8601 `date-time` string.

- **App layout:** domain apps are grouped under `apps/` (registered as `apps.users`), mirroring the role `src/` plays in other stacks.
- **Schema matches `spec/schema.sql`:** the persistence source of truth dictates DB-side `uuidv7()` + `now()` defaults, a `text` email, and a `users` table. Matching it meant going against a few Django idioms (see below) — a deliberate choice so the data layer is uniform across stacks.
- **IDs:** UUIDv7 generated DB-side via `db_default=Func('uuidv7')` (Postgres 18) — not Django's more idiomatic app-side `default=uuid.uuid7`, so the value comes back through `INSERT … RETURNING`.
- **Timestamps:** `timestamptz` (`USE_TZ`) with DB-side defaults via `db_default=Func('now')`. Django's idiomatic `auto_now_add` / `auto_now` are app-side, and its `Now()` renders `statement_timestamp()` rather than `now()` — hence the explicit `Func('now')` to match the contract.
- **DB columns / table:** snake_case for free (field names *are* the column names); `Meta.db_table = 'users'` overrides Django's default `users_user`.
- **Validation:** the DRF `UserSerializer` declares `email = EmailField()` explicitly, so format validation lives in the serializer even though the model column is a plain `TextField` — `id` and timestamps are read-only, so clients can't set them.
- **Errors:** RFC 9457 `application/problem+json` (`{ status, title, detail }`) via a custom DRF exception handler ([`config/exception_handler.py`](config/exception_handler.py)).
- **JSON only:** the browsable API renderer is disabled — every client, including browsers, gets JSON.
- **Create + retrieve only:** `UserViewSet` composes `CreateModelMixin` + `RetrieveModelMixin` on a `GenericViewSet`, so only `POST /users` and `GET /users/{id}` are routed — add mixins to expose more.
- **Default apps kept:** the stock `admin` / `auth` / `sessions` apps (and their tables) are left in rather than trimmed.

## Dev environment

- Runs entirely in containers. Compose Watch syncs the project for `runserver` hot reload and rebuilds on `pyproject.toml` / `uv.lock` changes.
- Dependencies are managed with uv; the `.venv` is built into the image (`uv sync --frozen`, the `npm ci` analogue) and never lives on the host.
- The app reads `PORT` (defaults to 8080).
