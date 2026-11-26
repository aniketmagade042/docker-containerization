#!/usr/bin/env bash
# Quick evidence collector. Run after `docker compose up -d --build`.
PORT="${WEB_PORT:-8000}"
echo "== docker compose ps =="; docker compose ps
echo; echo "== health endpoint =="; curl -s "http://localhost:${PORT}/health"; echo
echo; echo "== images =="; docker images | grep -E "REPOSITORY|guestbook"
echo; echo "== recent web logs =="; docker compose logs --tail 10 web
