# =============================================================================
# STAGE 1 — builder
# Compile the Vite/React app. Node, npm, and source stay here.
# Only the /app/dist output reaches production.
# =============================================================================
FROM node:22.14.0-alpine@sha256:01393fe5a51489b63da0ab51aa8e0a7ff9990132917cf20cfc3d46f5e36c0e48 AS builder

WORKDIR /app

# Manifests first — cached until package.json or package-lock.json changes
COPY package*.json ./

# npm ci writes nothing to a global cache by default.
RUN npm ci --prefer-offline

# Source arrives after deps — changes here don't bust the install cache
COPY . .

RUN npm run build


# =============================================================================
# STAGE 2 — runtime
# Clean nginx image. Only the compiled /dist lands here.
# No Node. No npm. No source code.
# =============================================================================
FROM nginx:1.29.0-alpine@sha256:9c0c8b866c995c32ab64bf81c188a1245548b63d834965eae0990062efae4616 AS runtime

ARG GIT_SHA=unknown
ARG VERSION=1.0.0
ARG MAINTAINER="bruce@bruceminanga.world"

LABEL org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.authors="${MAINTAINER}" \
      org.opencontainers.image.base.name="nginx:1.29.0-alpine"

# Copy only the compiled static assets from the builder
COPY --from=builder /app/dist /usr/share/nginx/html

# nginx:alpine already runs the worker processes as the unprivileged 'nginx'
# user. The master process must stay as root to bind port 80, which is
# standard and expected for nginx. No USER directive needed here.

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]