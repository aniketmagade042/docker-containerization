# Docker & Containerization Lab

A small web application containerized from source code to a running multi-container app:

**Source Code -> Dockerfile -> Image -> Container -> Docker Compose -> Running Application**

- **App:** Flask guestbook + PostgreSQL
- **Containers:** `web` (Gunicorn + Flask) and `db` (PostgreSQL 16)
- **Concepts shown:** optimized Dockerfile, networking, named volume, environment variables, health checks, Docker Compose
- **Environment:** run in GitHub Codespaces, because Docker Desktop would not install on my Windows version

## Architecture

```
Browser -- port 8000 --> [ web container: Flask + Gunicorn ]
                                |  appnet (private Docker network, host name "db")
                                v
                        [ db container: PostgreSQL ] -- pgdata volume (persistent)
```

The database port is not published to the host.

## Run it

```bash
git clone https://github.com/aniketmagade042/docker-containerization.git
cd docker-containerization
cp .env.example .env     # then set SECRET_KEY and POSTGRES_PASSWORD
docker compose up -d --build
```

Open the app on port 8000 and `/health` to check the database connection.

Stop: `docker compose down` (keeps data) | Wipe data: `docker compose down -v`

If `pip` inside the build cannot reach PyPI (see Challenges below), download the packages into a `wheels/` folder first and build with `Dockerfile.offline`, then run `docker compose up -d --no-build`.

## Dockerfile optimization

| Image | Size on disk |
|---|---|
| `python:3.12` (full base image) | 1.62 GB |
| `python:3.12-slim` | 179 MB |
| `guestbook-web:1.0` (slim base + app + dependencies) | 215 MB |

The optimized `Dockerfile` uses the slim base image, installs dependencies before copying code so Docker can cache the layer, avoids the pip cache, runs as a non-root user, uses Gunicorn, and adds a health check. `Dockerfile.naive` is a deliberately unoptimized version for comparison; I could not build it in my Codespace because of network problems, so I compared the base images instead.

## Persistence proof

1. Added an entry, ran `docker compose down` and `up`: the entry was still there (named volume `pgdata`).
2. Ran `docker compose down -v` and `up`: the entry was gone (volume removed).

## Learning notes

- [Containers, images and the Dockerfile](notes/01-containers-and-images.md)
- [Docker command cheat sheet](notes/02-docker-commands.md)
- [Networking, volumes, environment variables and Compose](notes/03-networking-volumes-env-compose.md)

## Evidence

| What | File |
|---|---|
| Successful image build | `screenshots/01-docker-build.png` |
| Image sizes (python:3.12, slim, my app) | `screenshots/02-docker-images.png` |
| Both services healthy in Docker Compose | `screenshots/03-compose-ps.png` |
| App running with a guestbook entry | `screenshots/04-running-app.png` |
| Health endpoint | `screenshots/04b-health.png` |
| Entry persists after `down` and `up` | `screenshots/05-persistence.png` |
| Data gone after `down -v` | `screenshots/05b-persistence-wiped.png` |
| New entry after the wipe | `screenshots/05c-new-entry-after-wipe.png` |
| Challenge: pip SSL errors during the build | `screenshots/06-challenge-pip-ssl-errors.png` |
| Fix: packages downloaded as wheels | `screenshots/07-fix-wheels-download.png` |
| Port 8000 forwarded in Codespaces | `screenshots/08-ports-forwarded.png` |

## Challenges and fixes

The image build failed because `pip` inside the container got timeouts and SSL EOF errors from PyPI, even after I added longer timeouts and retries and tried host networking. The Codespace itself could reach PyPI, so I downloaded the packages as wheel files there and built with `Dockerfile.offline`, which installs them with `--no-index --find-links`. After that the build finished in seconds and Compose started both containers healthy.

## Repo structure

```
app/                 Flask application
Dockerfile           optimized image
Dockerfile.offline   same image, installs from a local wheels folder
Dockerfile.naive     comparison only
docker-compose.yml   web + db, network, volume
.env.example         configuration template (copy to .env)
notes/               learning notes
scripts/verify.sh    collects evidence output
tests/               unit tests (run without Docker)
screenshots/         evidence
```

## Author

Aniket Magade | [LinkedIn](https://www.linkedin.com/in/aniket-magade-959601448/)
