# Stack comparison

Every backend implements the same contract ([`spec/openapi.yaml`](spec/openapi.yaml)) and is verified identically by [`conformance/`](conformance/). Internals stay idiomatic per stack — so the tables below show where the stacks **diverge** while producing the **same wire behavior**.

## Stack & tooling

| | go-net-http | python-django | ts-nestjs |
|---|---|---|---|
| Language / framework | Go 1.26 · stdlib `net/http` | Python 3.14 · Django 6 + DRF | TypeScript · NestJS 11 |
| Dependency manager | Go modules (`go.sum`) | uv (`uv.lock`) | npm (`package-lock.json`) |
| Data layer | sqlc + pgx (hand-written SQL, no ORM) | Django ORM + DRF | TypeORM |
| Dev server / reload | `go run .` (Compose Watch `sync+restart`) | `runserver` (Compose Watch) | `nest start --watch` (Compose Watch) |
| Migrations | hand-written SQL, goose (`go:embed`) | `makemigrations`, auto-named | TypeORM CLI, manually named |

## Data model (`User`)

| | go-net-http | python-django | ts-nestjs |
|---|---|---|---|
| UUIDv7 id | Postgres-native `uuidv7()` (DB-generated) | Python `uuid.uuid7()` (app-generated) | Postgres-native `uuidv7()` (DB-generated) |
| Timestamps set by | DB default (`now()`) | Python (`auto_now_add`) | DB default (`@CreateDateColumn`) |
| `timestamptz` | explicit (migration DDL) | free (`USE_TZ=True`) | explicit (`type: 'timestamptz'`) |
| snake_case columns | hand-written in SQL | free (field name *is* the column) | custom `SnakeNamingStrategy` |
| Table name | `users` | `users_user` | `users` |

## Contract behavior (same result, different mechanism)

| | go-net-http | python-django | ts-nestjs |
|---|---|---|---|
| Input validation | stdlib `net/mail.ParseAddress` | DRF serializer (`EmailField`) | class-validator + `ValidationPipe` |
| Duplicate email → `409` | `errors.As` → `*pgconn.PgError`, `Code == "23505"` | catch `IntegrityError`, `__cause__.sqlstate == '23505'` | catch `QueryFailedError`, `driverError.code === '23505'` |
| Malformed id → `404` | `uuid.Parse` error → `404` | DRF `get_object_or_404` (rejects bad UUID) | `ParseUUIDPipe({ errorHttpStatusCode: NOT_FOUND })` |
| RFC 9457 errors | `writeProblem` helper | DRF `EXCEPTION_HANDLER` + JSON-only renderer | global exception filter (`@Catch()`) |
| Host validation | none (stdlib) | `ALLOWED_HOSTS` (env-driven) | none (Express) |
| Routed endpoints | `createUser` + `getUser` (explicit `mux` registration) | `create` + `retrieve` (mixins on `GenericViewSet`) | `create` + `findOne` (rest in service, unrouted) |

All three reach the duplicate-detection result through the **same Postgres signal** (SQLSTATE `23505`) via different language APIs — a good example of "identical contract, idiomatic internals."
