# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MicroStack is a **microservices scaffold template**, not a single running service. Its purpose is to be cloned/used in two ways:

1. **As a scaffold**: `./init.sh <project-name>` copies the template's core files into a brand-new sibling directory, customizes `config/config.yaml` for that project, and generates fresh `README.md`/`docs/DEVELOPMENT.md` — producing an independent microservice project.
2. **Directly as a template**: run `app.py` in place via `./run.sh` for quick prototyping without scaffolding a new project.

The entire template is one FastAPI app (`app.py`) plus a small shared library (`shared/`) for config loading, logging, and MongoDB access. There is no test suite, linter, or CI configured in the repo.

Documentation (`README.md`, `USAGE.md`) is written primarily in Chinese (README also has English/Japanese sections); code comments, log messages, and CLI script output are in Chinese throughout — match that convention when editing existing files.

## Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally, dev mode (hot reload)
./run.sh --reload

# Run locally, custom port (auto-increments if occupied, up to 50 attempts)
./run.sh --port 8090

# Run locally, production mode (multiple uvicorn workers)
./run.sh --workers 4

# Run via Docker (builds a throwaway Dockerfile.tmp, tags <name>:latest)
./run-docker.sh --build
./run-docker.sh --detach                       # background
./run-docker.sh --build --port 8090 --name my-service

# Scaffold a brand-new project from this template
./init.sh my-awesome-service --port 8080 --git   # --git also runs git init + initial commit

# Interactive menu wrapping the three flows above (scaffold / run template / docker)
./start.sh

# Run the app directly without the wrapper script (equivalent to what run.sh does)
CONFIG_PATH="$(pwd)/config/config.yaml" PYTHONPATH="$(pwd)" python3 app.py
```

There are no `test`/`lint`/`build` commands defined anywhere in the repo (no `tests/` dir, no linter config, no CI). `pytest` is referenced only inside the docs `init.sh` generates for *new* scaffolded projects — it is not set up here.

### Access points once running

- Swagger UI: `http://<host>:<port>/docs`
- ReDoc: `http://<host>:<port>/redoc`
- Health check: `http://<host>:<port>/health`
- Runtime config introspection: `http://<host>:<port>/api/config`

## Architecture

### Entry point and request flow (`app.py`)

- Single-file FastAPI app. Adds the repo root to `sys.path` and imports the shared library as `shared.config.config`, `shared.utils.logger`, `shared.database.mongodb`.
- A module-level `config` singleton (see below) drives the app's `title`/`version`, CORS (`allow_origins=["*"]`), and the logger name/level.
- A `MongoDBConnection` is instantiated from `config.get('database.mongodb', {})` **only if that config section is non-empty**; when absent, `db` is `None` and every route falls back to hardcoded example data instead of touching a database. This "works with zero external services" fallback is the pattern to preserve when adding new routes — check `if db:` before querying.
- Routes: `GET /` (service banner), `GET /health` (liveness), `GET /api/items` + `POST /api/items` + `GET /api/items/{item_id}` (example CRUD demonstrating the DB-or-fallback pattern), `GET /api/config` (non-sensitive config introspection).
- `find_available_port()` in `app.py` duplicates the port-scanning logic also implemented in the shell scripts (see below) — when running `app.py` directly (not via `run.sh`), Python does its own scan starting from `$PORT` or `config.app.port`.
- `uvicorn.run(..., reload=debug)` — reload is tied to `app.debug` in `config.yaml`, not to a CLI flag, when launched this way.

### Shared library (`shared/`)

- `shared/config/config.py` — `Config` class reads YAML from `$CONFIG_PATH` (default `/app/config/config.yaml`, i.e. the Docker-container path; locally this is set to `<cwd>/config/config.yaml` by `run.sh`/`start.sh`). Exposes `config.get('dot.notation.key', default)` and `.app`/`.database`/`.redis` convenience properties. A module-level `config = Config()` singleton is what `app.py` imports. Note: `load_config()` is `@lru_cache`d on the *instance method*, so changing `CONFIG_PATH` after first access has no effect within a process.
- `shared/database/mongodb.py` — `MongoDBConnection` wraps `pymongo.MongoClient`; lazily connects on first `.database` access (not at construction), builds a `mongodb://user:pass@host:port` string only when both username and password are set.
- `shared/utils/logger.py` — `setup_logger(name, level)` returns a stdlib `logging.Logger` with a single stdout `StreamHandler`; guards against duplicate handlers on repeated calls.
- `redis` is listed in `requirements.txt` and has a `config.yaml` section, but there is no `shared/` module or app code that actually uses it yet — it's present for extension, not currently wired up.

### Configuration (`config/config.yaml`)

YAML values use a custom `${VAR:default}` interpolation syntax in comments/examples (e.g. `${MONGO_HOST:localhost}`) — **this is not resolved by `Config.load_config()`**, which just does a plain `yaml.safe_load`; there is no env-var substitution step in `shared/config/config.py`. Treat those `${...}` values in `config.yaml` as documentation of intended env vars, not functioning interpolation, unless you add resolution logic.

Sections: `app` (name/version/debug/host/port), `database.mongodb`, `redis`, `logging`, `security` (JWT secret/expiry — unused by any route currently), `monitoring` (health/metrics paths — only `/health` is actually implemented; `/metrics` is aspirational).

### Shell scripts — shared conventions

`init.sh`, `run.sh`, `run-docker.sh`, `start.sh` all: `set -e`, define the same ANSI color vars (`RED`/`GREEN`/`BLUE`/`YELLOW`/`NC`), and implement **their own independent copy** of `check_port`/`find_available_port` (bash, using `lsof`/`netstat`/`/dev/tcp` fallback) — this logic is *not* shared via a sourced file, so a port-scanning behavior change must be replicated in `run.sh`, `run-docker.sh`, and `app.py`'s Python equivalent separately.

- `init.sh` — scaffolds a new project: creates `config/`, `shared/{config,database,utils}/`, `tests/`, `docs/`; copies `app.py`, `shared/`, `config/config.yaml`, `requirements.txt`, `run.sh`, `run-docker.sh`, `.gitignore` from the scaffold source dir (`dirname $(realpath $0)`, i.e. wherever `init.sh` itself lives — supports running it from a different cwd); `sed`-rewrites `microstack-service` → project name and `port: 8080` → chosen port in the copied `config.yaml`; generates a project-specific `README.md` and `docs/DEVELOPMENT.md`; optionally `git init && git add . && git commit`.
- `run-docker.sh` — has **no static `Dockerfile`** in the repo; it writes `Dockerfile.tmp` inline (python:3.9-slim, non-root `app` user, `HEALTHCHECK` hitting `/health`) at build time and deletes it after `docker build`. Also creates a `microstack-network` Docker network if missing, and mounts `./config` read-only into the container at `/app/config` when present.
- `start.sh` — interactive menu (numbered prompts) that dispatches to `init.sh`, `run.sh --reload`, or `run-docker.sh`; must be run from the MicroStack root (checks for `app.py` and `init.sh` presence).

### Docs are the source of truth for behavior

`USAGE.md` (Chinese) and the three-language `README.md` describe the same three usage modes as above; `README.md`'s Chinese/Japanese sections additionally reference an `apps/` (example services) and `infrastructure/` directory that **do not exist in this repo** — do not assume those paths are present.
