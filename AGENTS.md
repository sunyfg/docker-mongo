# AGENTS.md

Local MongoDB dev environment for macOS via Docker Compose. No application code, no tests, no CI.

## Commands

- Start: `docker compose up -d`
- Status / logs: `docker compose ps`, `docker compose logs -f mongo`
- mongosh (inside container): `docker compose exec mongo mongosh`
- Stop (keeps data): `docker compose down`
- **Destroy data**: `docker compose down -v` — permanently deletes the `mongo_data` volume

## Setup

- `.env` is required (compose variables like `MONGO_ROOT_USERNAME` have no defaults). Create it: `cp .env.example .env`, then set real passwords (`openssl rand -hex 24`).
- `.env` and `.env.*` are gitignored (`.env.example` is the only one committed). Never commit real passwords.

## Critical: init script runs only once

`mongo/init/001_init.sh` is mounted to `/docker-entrypoint-initdb.d` and executes **only when the data volume is first initialized** (official mongo entrypoint).

- Editing the init script and running `docker compose restart` does **nothing**.
- To re-run init after editing `001_init.sh`: `docker compose down -v && docker compose up -d` (destroys all local data).
- The script creates the app user (`readWrite` on `MONGO_DATABASE`) and seeds `health_check`; no secrets are hardcoded — it reads container env vars.

## Behavior notes

- **`GLIBC_TUNABLES: glibc.pthread.rseq=1` in `compose.yaml` is required** — MongoDB 8.x refuses to start on Docker Desktop's linuxkit kernel 6.19–7.0.13 (SERVER-121912 TCMalloc/rseq incompatibility) and crash-loops. `=0` does NOT work; must be `=1`. Remove once the Docker Desktop VM kernel is ≥ 7.0.14 (`docker run --rm alpine uname -r`).
- Healthcheck authenticates as root (`$$` in `compose.yaml` escapes to `$` inside the container) — it is not a mere port check.
- App user authSource is `MONGO_DATABASE` (default `app`), not `admin`. Connection URI form:
  `mongodb://<user>:<pass>@127.0.0.1:<port>/<db>?authSource=<db>` (port/db from `.env`, defaults `27017`/`app`).
- Image is `MONGO_IMAGE` from `.env` (example pins `mongo:8.3.11`); README claims a pre-existing local image is used.
- `MONGO_INITDB_DATABASE` only controls which DB the entrypoint sees first; the app DB/user creation is done explicitly in `001_init.sh` via `MONGO_DATABASE`.

See `README.md` for full connection details (Chinese).
