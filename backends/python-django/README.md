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
- **IDs:** UUIDv7 via Python 3.14's stdlib `uuid.uuid7` — generated app-side, time-ordered, better index locality than v4.
- **Timestamps:** `timestamptz` automatically (`USE_TZ`), set via `auto_now_add` / `auto_now`, serialized as ISO-8601.
- **DB columns:** snake_case for free (Django field names *are* the column names); JSON stays camelCase via serializer `source=` mapping (`createdAt` ← `created_at`).
- **Validation:** the DRF `UserSerializer` — `email` is required/validated/unique; `id` and timestamps are read-only, so clients can't set them.
- **Errors:** RFC 9457 `application/problem+json` (`{ status, title, detail }`) via a custom DRF exception handler ([`config/exception_handler.py`](config/exception_handler.py)).
- **JSON only:** the browsable API renderer is disabled — every client, including browsers, gets JSON.
- **Create + retrieve only:** `UserViewSet` composes `CreateModelMixin` + `RetrieveModelMixin` on a `GenericViewSet`, so only `POST /users` and `GET /users/{id}` are routed — add mixins to expose more.
- **Default apps kept:** the stock `admin` / `auth` / `sessions` apps (and their tables) are left in rather than trimmed.

## Dev environment

- Runs entirely in containers. Compose Watch syncs the project for `runserver` hot reload and rebuilds on `pyproject.toml` / `uv.lock` changes.
- Dependencies are managed with uv; the `.venv` is built into the image (`uv sync --frozen`, the `npm ci` analogue) and never lives on the host.
- The app reads `PORT` (defaults to 8080).
