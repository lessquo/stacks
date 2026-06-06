.PHONY: go-net-http go-net-http-migrate go-net-http-sqlc python-django python-django-makemigrations python-django-migrate ts-nestjs ts-nestjs-deps ts-nestjs-migrate ts-nestjs-migration conformance-go-net-http conformance-python-django conformance-ts-nestjs

go-net-http:
	docker compose -f backends/go-net-http/compose.yaml up --build --watch

go-net-http-migrate:
	docker compose -f backends/go-net-http/compose.yaml run --rm app go run . migrate

# Regenerate the type-safe query layer from queries/ + migrations/ (schema source).
go-net-http-sqlc:
	docker run --rm -v "$(CURDIR)/backends/go-net-http":/src -w /src sqlc/sqlc:1.31.1 generate

python-django:
	docker compose -f backends/python-django/compose.yaml up --build --watch

python-django-makemigrations:
	docker compose -f backends/python-django/compose.yaml run --rm --no-deps \
	  -v "$(CURDIR)/backends/python-django/apps":/app/apps app \
	  uv run python manage.py makemigrations

python-django-migrate:
	docker compose -f backends/python-django/compose.yaml run --rm \
	  -v "$(CURDIR)/backends/python-django/apps":/app/apps app \
	  uv run python manage.py migrate

ts-nestjs:
	docker compose -f backends/ts-nestjs/compose.yaml up --build --watch

# Populate host node_modules from the image for editor IntelliSense (app runs in containers).
ts-nestjs-deps:
	docker compose -f backends/ts-nestjs/compose.yaml build
	rm -rf backends/ts-nestjs/node_modules
	cid=$$(docker create ts-nestjs-app) && docker cp "$$cid:/app/node_modules" backends/ts-nestjs/node_modules && docker rm "$$cid"

ts-nestjs-migrate:
	docker compose -f backends/ts-nestjs/compose.yaml run --rm \
	  -v "$(CURDIR)/backends/ts-nestjs/src":/app/src app npm run migration:run

ts-nestjs-migration:
	docker compose -f backends/ts-nestjs/compose.yaml run --rm \
	  -v "$(CURDIR)/backends/ts-nestjs/src":/app/src app \
	  npm run migration:generate -- src/migrations/$(name)

# One-shot conformance: spin up a throwaway stack with a fresh DB, run Schemathesis,
# tear it down. No need to start the backend separately.
conformance-go-net-http:
	conformance/schemathesis/run.sh go-net-http "go run . migrate"

conformance-python-django:
	conformance/schemathesis/run.sh python-django "uv run python manage.py migrate"

conformance-ts-nestjs:
	conformance/schemathesis/run.sh ts-nestjs "npm run migration:run"
