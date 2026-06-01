# Stack comparison

Every backend implements the same contract ([`spec/openapi.yaml`](spec/openapi.yaml)) and is verified identically by [`conformance/`](conformance/). Internals stay idiomatic per stack — so the tables below show where the stacks **diverge** while producing the **same wire behavior**.

## Stack & tooling

| | python-django | ts-nestjs |
|---|---|---|
| Language / framework | Python 3.14 · Django 6 + DRF | TypeScript · NestJS 11 |
| Dependency manager | uv (`uv.lock`) | npm (`package-lock.json`) |
| Data layer | Django ORM + DRF | TypeORM |
| Dev server / reload | `runserver` (both via Compose Watch) | `nest start --watch` |
| Migrations | `makemigrations`, auto-named | TypeORM CLI, manually named |

## Data model (`User`)

| | python-django | ts-nestjs |
|---|---|---|
| UUIDv7 id | Python `uuid.uuid7()` (app-generated) | Postgres-native `uuidv7()` (DB-generated) |
| Timestamps set by | Python (`auto_now_add`) | DB default (`@CreateDateColumn`) |
| `timestamptz` | free (`USE_TZ=True`) | explicit (`type: 'timestamptz'`) |
| snake_case columns | free (field name *is* the column) | custom `SnakeNamingStrategy` |
| Table name | `users_user` | `users` |

## Contract behavior (same result, different mechanism)

| | python-django | ts-nestjs |
|---|---|---|
| Input validation | DRF serializer (`EmailField`) | class-validator + `ValidationPipe` |
| Duplicate email → `409` | catch `IntegrityError`, `__cause__.sqlstate == '23505'` | catch `QueryFailedError`, `driverError.code === '23505'` |
| Malformed id → `404` | DRF `get_object_or_404` (rejects bad UUID) | `ParseUUIDPipe({ errorHttpStatusCode: NOT_FOUND })` |
| RFC 9457 errors | DRF `EXCEPTION_HANDLER` + JSON-only renderer | global exception filter (`@Catch()`) |
| Host validation | `ALLOWED_HOSTS` (env-driven) | none (Express) |
| Routed endpoints | `create` + `retrieve` (mixins on `GenericViewSet`) | `create` + `findOne` (rest in service, unrouted) |

Both reach the duplicate-detection result through the **same Postgres signal** (SQLSTATE `23505`) via different language APIs — a good example of "identical contract, idiomatic internals."
