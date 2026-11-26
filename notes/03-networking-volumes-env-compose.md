# Networking, Volumes, Environment Variables and Compose

## Container networking
- Containers on the same **user-defined network** reach each other by **service name** (Docker's built-in DNS). In this project the app connects to host `db`, not an IP address.
- **Port publishing** (`ports: "8000:8000"`) maps host port -> container port, so your browser can reach the container.
- Network drivers: `bridge` (default, single host), `host` (shares host network), `none`.
- The database has **no published port**: only the web container can reach it. That is the same least-exposure idea as a private subnet in the cloud.

## Volumes and persistent data
A container's filesystem disappears when the container is removed. To keep data:

| Type | Example | Use |
|---|---|---|
| **Named volume** | `pgdata:/var/lib/postgresql/data` | Databases, managed by Docker |
| **Bind mount** | `./code:/app` | Live-editing code in development |
| **tmpfs** | in-memory | Temporary secrets/cache |

Proof of persistence (take a screenshot of each step):
1. `docker compose up -d --build` and add a guestbook entry.
2. `docker compose down` (containers gone, volume stays).
3. `docker compose up -d` and refresh: **the entry is still there.**
4. `docker compose down -v` then `up -d`: the entry is **gone** (volume deleted).

## Environment variables and secrets
- Config lives outside the image: the same image runs in dev and production.
- Compose reads `.env` automatically and substitutes `${VARIABLES}` in `docker-compose.yml`.
- `.env` is in `.gitignore`; only `.env.example` is committed.
- Never `COPY` secrets into an image or hard-code them in a Dockerfile (anyone with the image can read them via `docker history`).
- `${SECRET_KEY:?message}` makes Compose fail loudly if a required value is missing.

## Docker Compose
Compose describes a multi-container app in one YAML file.

| Key | Meaning |
|---|---|
| `services` | The containers (here `web` and `db`) |
| `build` / `image` | Build from a Dockerfile, or use a prebuilt image |
| `ports` | Publish container ports to the host |
| `environment` | Environment variables |
| `volumes` | Persistent storage |
| `networks` | Which networks the service joins |
| `depends_on` + `healthcheck` | Start order, waiting for a *healthy* dependency |
| `restart` | Restart policy (`unless-stopped`) |

## Troubleshooting
| Symptom | Likely cause |
|---|---|
| `SECRET_KEY` error on `up` | `.env` missing or variable not set |
| Web container restarts | Check `docker compose logs web` (often DB URL or password) |
| Port already in use | Change `WEB_PORT` in `.env` |
| Password changed but DB won't accept it | Postgres only reads the password on first start: run `docker compose down -v` once |
| `permission denied` on Linux | Add your user to the `docker` group or use `sudo` |
| Docker Desktop won't start (Windows) | Enable virtualization in BIOS and WSL 2 |
