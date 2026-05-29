.PHONY: ts-nestjs

ts-nestjs:
	docker compose -f backends/ts-nestjs/compose.yaml up --watch
