.PHONY: ts-nestjs ts-nestjs-deps ts-nestjs-migrate ts-nestjs-migration

ts-nestjs:
	docker compose -f backends/ts-nestjs/compose.yaml up --watch

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
