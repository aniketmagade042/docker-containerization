# Docker & Containerization Lab

A small web application containerized from source code to a running multi-container app:

**Source Code -> Dockerfile -> Image -> Container -> Docker Compose -> Running Application**

- **App:** Flask guestbook + PostgreSQL
- **Containers:** `web` (Gunicorn + Flask) and `db` (PostgreSQL 16)
- **Concepts shown:** optimized Dockerfile, networking, named volume, environment variables, health checks, Docker Compose

## Architecture

```
Browser -- localhost:8000 --> [ web container: Flask + Gunicorn ]
                                      |  appnet (private Docker network, host name "db")
                                      v
                              [ db container: PostgreSQL ] -- pgdata volume (persistent)
```

The database port is **not** published to the host.

## Run it

Requires Docker Desktop (or Docker Engine + Compose plugin).

```bash
git clone https://github.com/aniketmagade042/docker-containerization-lab.git
cd docker-containerization-lab
cp .env.example .env          # Windows: copy .env.example .env
# edit .env: set SECRET_KEY and POSTGRES_PASSWORD
docker compose up -d --build
```

Open http://localhost:8000 and http://localhost:8000/health

Stop: `docker compose down` (keeps data) | Wipe data: `docker compose down -v`

## Dockerfile optimization results

Build both Dockerfiles and fill in your sizes:

```bash
docker build -t guestbook-naive -f Dockerfile.naive .
docker build -t guestbook-web:1.0 .
docker images | grep guestbook
```

| Image | Dockerfile | Size |
|---|---|---|
| guestbook-naive | `Dockerfile.naive` (full base image, no caching, root user) | `<fill in>` |
| guestbook-web:1.0 | `Dockerfile` (slim base, layer caching, non-root, healthcheck) | `<fill in>` |

## Persistence proof

1. Add an entry in the app.
2. `docker compose down`, then `docker compose up -d`: the entry is still there (named volume `pgdata`).
3. `docker compose down -v`, then `up -d`: the entry is gone (volume removed).

## Learning notes

- [Containers, images and the Dockerfile](notes/01-containers-and-images.md)
- [Docker command cheat sheet](notes/02-docker-commands.md)
- [Networking, volumes, environment variables and Compose](notes/03-networking-volumes-env-compose.md)

## Evidence (add your screenshots to `screenshots/`)

| What | File |
|---|---|
| `docker --version` and a successful build | `screenshots/01-docker-build.png` |
| `docker images` showing both image sizes | `screenshots/02-docker-images.png` |
| `docker compose ps` with both services healthy | `screenshots/03-compose-ps.png` |
| The running app at localhost:8000 with an entry | `screenshots/04-running-app.png` |
| Entry still present after `down` and `up` | `screenshots/05-persistence.png` |

## Challenges and fixes

- `<Describe a real problem you hit and how you solved it>`

## Repo structure

```
app/                 Flask application
Dockerfile           optimized image
Dockerfile.naive     comparison only
docker-compose.yml   web + db, network, volume
.env.example         configuration template (copy to .env)
notes/               learning notes
scripts/verify.sh    collects evidence output
tests/               unit tests (run without Docker)
```

## Author

Aniket Magade | [LinkedIn](https://www.linkedin.com/in/aniket-magade-959601448/)
