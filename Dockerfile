# ---- Optimized Dockerfile ----
# Small base image (slim instead of the full Debian-based image)
FROM python:3.12-slim

# Don't write .pyc files; print logs immediately (shows up in `docker logs`)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy ONLY requirements first: Docker caches this layer, so dependencies
# are not reinstalled every time you change application code.
COPY requirements.txt .
RUN pip install --no-cache-dir --default-timeout=100 --retries 10 -r requirements.txt

# Run as a non-root user (security best practice)
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copy application code last (it changes most often)
COPY app/ .
USER appuser

EXPOSE 8000

# Lets Docker (and Compose) know whether the app is really healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"

# Production server instead of Flask's development server
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000", "--workers", "2"]
