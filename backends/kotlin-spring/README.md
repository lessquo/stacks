# kotlin-spring

Kotlin + Spring Boot implementation of the shared `stacks` API. The contract it implements lives in [`spec/openapi.yaml`](../../spec/openapi.yaml).

## Stack

- Kotlin 2.2, Spring Boot 4 (Spring MVC, servlet) on embedded Tomcat
- PostgreSQL 18 via Spring Data JPA + Hibernate 7
- Flyway for migrations
- Gradle (Kotlin DSL) build
- Container-first: Docker Compose for everything; nothing is installed on the host.

## Running

All targets live in the repo-root `Makefile`; run them from the repo root:

```bash
make kotlin-spring-migrate   # start Postgres + apply migrations (one-shot), then exits
make kotlin-spring           # start the app with hot reload → http://localhost:8080
```

## Migrations

Manual (not auto-run on boot — `spring.flyway.enabled=false`). Migration files are hand-written SQL in [`src/main/resources/db/migration/`](src/main/resources/db/migration/) (`V<n>__<name>.sql`); Flyway tracks applied ones in `flyway_schema_history`. There is no generator and no down/rollback — Flyway versioned migrations are forward-only (undo is a paid feature), so reversing means writing a new forward migration.

```bash
make kotlin-spring-migrate   # apply pending migrations
```

## Implementation choices

Stack-local detail not captured by [comparison.md](../../comparison.md), which has the cross-stack mechanics (ids, timestamps, validation, errors, routing):

- **Wiring is all convention:** `@RestController` → `@Service` → `JpaRepository`, discovered by component scan and joined by constructor injection — no explicit registration. The repository is just an interface; Spring Data generates the implementation at runtime.
- **Single-statement create:** `@Generated(event = [INSERT])` on the DB-defaulted columns (`id`, `created_at`, `updated_at`) makes Hibernate omit them from the INSERT and read them back via `RETURNING` — one round-trip, no follow-up `SELECT`.
- **RFC 9457 is native:** Spring's built-in `ProblemDetail` (`spring.mvc.problemdetails.enabled=true`) turns validation failures into `400 application/problem+json`; a `@RestControllerAdvice` maps SQLSTATE `23505` → `409`. A malformed path id is parsed explicitly and treated as `404`.
- **Boot 4 modular autoconfig:** `flyway-core` alone doesn't run — Boot 4 split autoconfiguration into per-tech modules, so `spring-boot-flyway` is required alongside it.
- **Wire vs DB types:** `CreateUserRequest` / `UserResponse` are decoupled from the `User` entity; `created_at` ← `createdAt` comes free from Spring's snake_case naming strategy.

## Dev environment

- Runs entirely in containers. Compose Watch syncs `src/` and restarts the container (`sync+restart`); the dev image runs `./gradlew bootRun`, which recompiles on restart. Heavier than the other stacks (full JVM + Spring context restart) — Spring DevTools is a possible refinement if the loop becomes a drag.
- The Gradle wrapper lives in the image; nothing (no JDK, no Gradle) is installed on the host. The app reads `PORT` (defaults to 8080) and `DB_*` env.
