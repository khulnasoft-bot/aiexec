# syntax=docker/dockerfile:1
# Keep this syntax directive! It's used to enable Docker BuildKit
#
# Backend-only Primeagent image
# - No frontend code or assets
# - No Playwright

################################
# BUILDER
################################
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# Required for apify-client
ENV RUSTFLAGS='--cfg reqwest_unstable'

# Install build dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        build-essential \
        gcc \
        git \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only backend source (excludes frontend)
COPY ./src/backend ./src/backend
COPY ./src/wfx ./src/wfx

# Create venv and install primeagent-base with dependencies
# Using uv pip instead of uv sync to avoid workspace complexities
RUN uv venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"
ENV VIRTUAL_ENV="/app/.venv"

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install ./src/wfx "./src/backend/base[complete,postgresql]"

################################
# RUNTIME
################################
FROM python:3.12.12-slim-trixie AS runtime

# Install minimal runtime dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        curl \
        git \
        libpq5 \
        gnupg \
        xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for npx-based MCP stdio servers)
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then NODE_ARCH="x64"; \
       elif [ "$ARCH" = "arm64" ]; then NODE_ARCH="arm64"; \
       else NODE_ARCH="$ARCH"; fi \
    && NODE_VERSION=$(curl -fsSL https://nodejs.org/dist/latest-v22.x/ \
                    | grep -oP "node-v\K[0-9]+\.[0-9]+\.[0-9]+(?=-linux-${NODE_ARCH}\.tar\.xz)" \
                    | head -1) \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1 \
    && npm install -g npm@latest \
    && npm cache clean --force

# Create non-root user
RUN useradd --uid 1000 --gid 0 --no-create-home --home-dir /app/data user

# Copy only the virtual environment
COPY --from=builder --chown=1000:0 /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# Create home directory and ensure proper ownership
# The user needs write access to /app/data (home) and /app (workdir)
# Note: .venv is already owned by 1000:0 via COPY --chown above, so no recursive chown needed
RUN mkdir -p /app/data && chown -R 1000:0 /app/data && chown 1000:0 /app

LABEL org.opencontainers.image.title=primeagent-backend
LABEL org.opencontainers.image.authors=['Primeagent']
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.url=https://github.com/khulnasoft-bot/primeagent
LABEL org.opencontainers.image.source=https://github.com/khulnasoft-bot/primeagent

USER user
WORKDIR /app

ENV PRIMEAGENT_HOST=0.0.0.0
ENV PRIMEAGENT_PORT=7860

CMD ["python", "-m", "primeagent", "run", "--backend-only"]
