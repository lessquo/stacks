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

Stack-local detail not captured by [comparison.md](../../comparison.md), which has the cross-stack mechanics (ids, timestamps, validation, errors, routing):

- **Structure:** classic NestJS layering via DI — `UsersController` (routes) delegates to `UsersService`, which uses the injected TypeORM repository, all wired in `UsersModule`.
- **Validation:** the global `ValidationPipe({ whitelist: true })` strips unknown body properties before they reach the DTO.
- **Unrouted CRUD:** `findAll` / `update` / `remove` exist in `UsersService` but aren't routed — ready to expose when the spec adds them.

## Dev environment

- Runs entirely in containers. Compose Watch syncs `src/` for hot reload and rebuilds on `package.json` / `tsconfig.json` changes.
- `node_modules` lives in the image, not the host. `make ts-nestjs-deps` copies it to the host purely so the editor's TypeScript server resolves imports — re-run after changing dependencies.
- The app reads `PORT` (defaults to 8080).
