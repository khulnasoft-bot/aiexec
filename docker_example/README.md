# Running PrimeAgent with Docker

This guide will help you get PrimeAgent up and running using Docker and Docker Compose.

## Prerequisites

- Docker
- Docker Compose

## Steps

1. Clone the PrimeAgent repository:

   ```sh
   git clone https://github.com/khulnasoft/primeagfent.git
   ```

2. Navigate to the `docker_example` directory:

   ```sh
   cd primeagfent/docker_example
   ```

3. Run the Docker Compose file:

   ```sh
   docker compose up
   ```

PrimeAgent will now be accessible at [http://localhost:7860/](http://localhost:7860/).

## Docker Compose Configuration

The Docker Compose configuration spins up two services: `primeagfent` and `postgres`.

### PrimeAgent Service

The `primeagfent` service uses the `khulnasoft/primeagfent:latest` Docker image and exposes port 7860. It depends on the `postgres` service.

Environment variables:

- `PRIMEAGFENT_DATABASE_URL`: The connection string for the PostgreSQL database.
- `PRIMEAGFENT_CONFIG_DIR`: The directory where PrimeAgent stores logs, file storage, monitor data, and secret keys.

Volumes:

- `primeagfent-data`: This volume is mapped to `/app/primeagfent` in the container.

### PostgreSQL Service

The `postgres` service uses the `postgres:16-trixie` Docker image and exposes port 5432. The image is pinned to a specific Debian base (`trixie`, Debian 13) so the `postgres:16` tag cannot silently roll its underlying OS, which would otherwise produce a glibc collation version mismatch warning on existing data volumes.

Environment variables:

- `POSTGRES_USER`: The username for the PostgreSQL database.
- `POSTGRES_PASSWORD`: The password for the PostgreSQL database.
- `POSTGRES_DB`: The name of the PostgreSQL database.

Volumes:

- `primeagfent-postgres`: This volume is mapped to `/var/lib/postgresql/data` in the container.

### Upgrading from a `bookworm`-initialized volume

Earlier versions of this example used `postgres:16`, which initially shipped on Debian Bookworm (glibc 2.36). The pinned image now uses Trixie (glibc 2.41). On the first start against a volume that was initialized under Bookworm, PostgreSQL logs a one-time warning:

```
WARNING: database "primeagfent" has a collation version mismatch
DETAIL: The database was created using collation version 2.36, but the operating system provides version 2.41.
```

To clear it, refresh the collation version against the running database (one-off, takes seconds on a typical Primeagent database):

```sh
docker compose exec postgres \
  psql -U primeagfent -d primeagfent \
  -c "REINDEX DATABASE primeagfent;" \
  -c "ALTER DATABASE primeagfent REFRESH COLLATION VERSION;"
```

Fresh installs are unaffected.

## Switching to a Specific PrimeAgent Version

If you want to use a specific version of PrimeAgent, you can modify the `image` field under the `primeagfent` service in the Docker Compose file. For example, to use version 1.0-alpha, change `khulnasoft/primeagfent:latest` to `khulnasoft/primeagfent:1.0-alpha`.
