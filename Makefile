.PHONY: ts-nestjs ts-nestjs-deps ts-nestjs-migrate ts-nestjs-migration python-django python-django-makemigrations python-django-migrate conformance-schemathesis

# Base URL of the running backend under test. Override per stack/host if needed.
BASE_URL ?= http://host.docker.internal:8080

ts-nestjs:
	docker compose -f backends/ts-nestjs/compose.yaml up --build --watch

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

# Run a conformance suite against a backend already running on BASE_URL.
conformance-schemathesis:
	docker run --rm -v "$(CURDIR)/spec":/spec \
	  schemathesis/schemathesis:4.20.3 run /spec/openapi.yaml --url $(BASE_URL)
