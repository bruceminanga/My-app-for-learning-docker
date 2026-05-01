# =============================================================================
# STAGE 1 — builder
# Install dependencies in isolation. The compiler, pip, and wheel never
# reach the production image.
# =============================================================================
FROM python:3.12-slim@sha256:ac212230555ffb7ec17c214fb4cf036ced11b30b5b460994376b0725c7f6c151 AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install/lib/python3.12/site-packages \
    PATH=/install/bin:$PATH

# Manifests first — this layer is cached until requirements change
COPY requirements.txt .

# Install into an explicit prefix so we can surgically copy it to runtime.
# --no-cache-dir: nothing written to cache, so nothing to clean.
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# =============================================================================
# STAGE 2 — runtime
# Clean slate. Only installed packages + source land here.
# No pip. No compiler. No build tools.
# =============================================================================
FROM python:3.12-slim@sha256:ac212230555ffb7ec17c214fb4cf036ced11b30b5b460994376b0725c7f6c151 AS runtime

# ---------------------------------------------------------------------------
# OCI labels — injected at build time by CI:
#   docker build \
#     --build-arg GIT_SHA=$(git rev-parse HEAD) \
#     --build-arg VERSION=1.0.0 \
#     -t app1:1.0.0 .
# ---------------------------------------------------------------------------
ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"

LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="python:3.12-slim"

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install/lib/python3.12/site-packages \
    PATH=/install/bin:$PATH

# Pull only the installed packages from the builder stage
COPY --from=builder /install /install

# Non-root user — drop privileges before source arrives
RUN useradd --no-create-home --shell /bin/false appuser
USER appuser

# Source arrives last — changes here don't bust the dependency cache
COPY --chown=appuser:appuser . .

EXPOSE 8000

CMD ["gunicorn", "app1.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--timeout", "120"]