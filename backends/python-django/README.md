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

Stack-local detail not captured by [comparison.md](../../comparison.md), which has the cross-stack mechanics (ids, timestamps, validation, errors, routing):

- **App layout:** domain apps are grouped under `apps/` (registered as `apps.users`), mirroring the role `src/` plays in other stacks.
- **Schema matches `spec/schema.sql`, against Django's grain:** matching the SoT meant `db_default=Func('uuidv7')` / `db_default=Func('now')` (Django's idiomatic `auto_now_add` / `auto_now` are app-side, and `Now()` renders `statement_timestamp()`, not `now()`), `Meta.db_table = 'users'` (over the default `users_user`), and a `TextField` email column — deliberate overrides so the data layer is uniform across stacks.
- **Validation decoupled from storage:** the DRF `UserSerializer` declares `email = EmailField()` explicitly, so format validation survives even though the model column is a plain `TextField`; `id` and timestamps are read-only, so clients can't set them.
- **JSON only:** the browsable API renderer is disabled — every client, including browsers, gets JSON.
- **Default apps kept:** the stock `admin` / `auth` / `sessions` apps (and their tables) are left in rather than trimmed.

## Dev environment

- Runs entirely in containers. Compose Watch syncs the project for `runserver` hot reload and rebuilds on `pyproject.toml` / `uv.lock` changes.
- Dependencies are managed with uv; the `.venv` is built into the image (`uv sync --frozen`, the `npm ci` analogue) and never lives on the host.
- The app reads `PORT` (defaults to 8080).
