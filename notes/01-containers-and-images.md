# Containers, Images and the Dockerfile

## Containers vs virtual machines

| | Virtual machine | Container |
|---|---|---|
| What it virtualises | Hardware (each VM has its own full OS) | The OS user space (shares the host kernel) |
| Size | GBs | MBs |
| Start time | Minutes | Seconds or less |
| Isolation | Strong (separate kernel) | Process-level (namespaces + cgroups) |
| Best for | Different OSes, strong isolation | Packaging and running apps consistently |

Analogy: a VM is a whole house with its own plumbing; a container is a furnished apartment that shares the building's plumbing.

## Docker architecture
- **Docker client (`docker` CLI):** what you type commands into.
- **Docker daemon (`dockerd`):** does the real work (builds images, runs containers).
- **Image:** a read-only template made of layers (app + dependencies + OS files).
- **Container:** a running instance of an image, with a thin writable layer on top.
- **Registry (Docker Hub):** where images are stored and pulled from.

Flow: `Dockerfile --build--> Image --run--> Container`

## Dockerfile instructions
| Instruction | Purpose |
|---|---|
| `FROM` | Base image to start from |
| `WORKDIR` | Working directory inside the image |
| `COPY` | Copy files from your machine into the image |
| `RUN` | Run a command at build time (install packages) |
| `ENV` | Set environment variables |
| `EXPOSE` | Documents the port the app listens on |
| `USER` | Run as a non-root user |
| `HEALTHCHECK` | How Docker tests the app is healthy |
| `CMD` | Default command when the container starts |

## Dockerfile optimization (what this repo does)
1. **Slim base image:** `python:3.12-slim` is much smaller than `python:3.12`.
2. **Layer caching:** copy `requirements.txt` and install dependencies *before* copying code, so code changes don't reinstall everything.
3. **`--no-cache-dir`:** keeps pip's download cache out of the image.
4. **`.dockerignore`:** keeps `.git`, `.env`, notes and screenshots out of the build context.
5. **Non-root user:** limits damage if the app is compromised.
6. **Production server:** Gunicorn instead of Flask's dev server.
7. **`HEALTHCHECK`:** lets Compose wait for a healthy service.

Measure it yourself:
```bash
docker build -t guestbook-naive -f Dockerfile.naive .
docker build -t guestbook-web:1.0 .
docker images | grep guestbook      # compare the SIZE column
```
Record both sizes in the README table.
