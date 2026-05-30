# ts-nestjs

TypeScript + NestJS implementation of the shared `stacks` API. The contract it implements lives in [`spec/openapi.yaml`](../../spec/openapi.yaml).

## Stack

- TypeScript, NestJS 11
- TypeORM + PostgreSQL 18
- Container-first: Docker Compose for everything; nothing is installed on the host.

## Running

All targets live in the repo-root `Makefile`; run them from the repo root:

```bash
make ts-nestjs-migrate   # start Postgres + apply migrations (one-shot), then exits
make ts-nestjs           # start the app with hot reload → http://localhost:8080
make ts-nestjs-deps      # optional: copy node_modules to the host for editor IntelliSense
```

## Migrations

Manual (not auto-run on boot). The TypeORM CLI DataSource is [`src/data-source.ts`](src/data-source.ts).

```bash
make ts-nestjs-migration name=AddSomething   # generate a migration from entity changes
make ts-nestjs-migrate                         # apply pending migrations
```

## Implementation choices

Internal, idiomatic-to-this-stack decisions. The shared contract stays implementation-neutral — on the wire these are just a `uuid` string and an ISO-8601 `date-time` string.

- **IDs:** UUIDv7 via Postgres-native `uuidv7()` — time-ordered, better index locality than v4.
- **Timestamps:** `timestamptz` (UTC), serialized as ISO-8601.
- **DB columns:** snake_case (`created_at`, …) via a custom `SnakeNamingStrategy`; TS properties and JSON stay camelCase.
- **Validation:** global `ValidationPipe({ whitelist: true })` + `class-validator`; the path `id` is validated as a UUID (`ParseUUIDPipe`).
- **Errors:** RFC 9457 `application/problem+json` (`{ status, title, detail }`) via a global exception filter.
- **Unrouted CRUD:** `findAll` / `update` / `remove` are implemented in `UsersService` but not exposed (the contract defines only create + get-by-id) — ready to route when the spec adds them.

## Dev environment

- Runs entirely in containers. Compose Watch syncs `src/` for hot reload and rebuilds on `package.json` / `tsconfig.json` changes.
- `node_modules` lives in the image, not the host. `make ts-nestjs-deps` copies it to the host purely so the editor's TypeScript server resolves imports — re-run after changing dependencies.
- The app reads `PORT` (defaults to 8080).
