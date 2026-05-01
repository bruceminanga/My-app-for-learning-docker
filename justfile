# ----------------------------
# All docker compose commands for dev and prod environments, with git metadata injection
# ----------------------------

git_sha     := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`
version     := `git describe --tags --abbrev=0 2>/dev/null || echo "1.0.0"`
compose_dev := "docker compose -f compose.dev.yml"
compose     := "docker compose"

# List all available commands
default:
    @just --list

# ----------------------------
# Dev workflow
# ----------------------------

# Build fresh and start all services (dev) - single shortcut
dev:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose_dev}} up --build

# Start all services (dev)
dev-up:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose_dev}} up

# Stop all services (dev)
dev-down:
    {{compose_dev}} down

# Build all images fresh, no cache (dev)
dev-build:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose_dev}} build --no-cache

# Build all images using cache (dev)
dev-build-fast:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose_dev}} build

# Down + up in one shot (dev)
dev-restart: dev-down dev-up

# Follow logs for all services (dev)
dev-logs:
    {{compose_dev}} logs -f

# Show running containers (dev)
dev-ps:
    {{compose_dev}} ps

# Show only running containers with details (dev)
dev-ps-running:
    {{compose_dev}} ps --status=running --format "table {{{{.Name}}}}\t{{{{.Service}}}}\t{{{{.Status}}}}\t{{{{.Ports}}}}"

# Stop containers and remove images (dev)
dev-clean:
    {{compose_dev}} down --rmi all --volumes --remove-orphans

# ----------------------------
# Prod workflow
# ----------------------------

# Start all services (prod)
up:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose}} up -d

# Stop all services (prod)
down:
    {{compose}} down

# Build all images fresh, no cache (prod)
build:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose}} build --no-cache

# Build all images using cache (prod)
build-fast:
    GIT_SHA={{git_sha}} VERSION={{version}} {{compose}} build

# Down + up in one shot (prod)
restart: down up

# Follow logs for all services (prod)
logs:
    {{compose}} logs -f

# Show running containers (prod)
ps:
    {{compose}} ps

# Show only running containers with details (prod)
ps-running:
    {{compose}} ps --status=running --format "table {{{{.Name}}}}\t{{{{.Service}}}}\t{{{{.Status}}}}\t{{{{.Ports}}}}"

# Stop containers and remove images (prod)
clean:
    {{compose}} down --rmi all --volumes --remove-orphans


# ----------------------------
# Cleanup
# ----------------------------

# Full Docker system prune - removes everything unused
prune:
    docker system prune -af --volumes

# ----------------------------
# Info
# ----------------------------

# Inspect OCI labels on all images
labels:
    #!/usr/bin/env bash
    for img in my-app-backend:latest my-app-frontend:latest; do
        echo "=== $img ==="
        docker inspect $img --format '{{{{ json .Config.Labels }}}}' | jq
    done

# Print current git SHA and version
info:
    @echo "GIT_SHA = {{git_sha}}"
    @echo "VERSION = {{version}}"
