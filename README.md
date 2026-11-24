[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/spliit?utm_medium=integration&utm_source=button&utm_campaign=spliit)

# Spliit on Railway

One-click Railway template for [Spliit](https://github.com/spliit-app/spliit), a free, open-source alternative to Splitwise for sharing expenses with friends, family and roommates.

## What it deploys

| Service | Source | What it does |
|---|---|---|
| **Spliit** | this repo (`Dockerfile`, official `ghcr.io/spliit-app/spliit:1.30.0` pinned by digest) | The Next.js web app on `$PORT`, public Railway domain, health check `/api/health/readiness`. Runs the Prisma migrations before it starts. |
| **Postgres** | Railway's PostgreSQL | Stores every group, participant and expense, on its own volume. |

Spliit itself is stateless; all data lives in Postgres, so it survives redeploys and restarts.

## Variables

The deploy form asks for nothing. The Spliit service gets:

| Variable | Default | Notes |
|---|---|---|
| `POSTGRES_PRISMA_URL` | `${{Postgres.DATABASE_URL}}` | Connection used by the app. |
| `POSTGRES_URL_NON_POOLING` | `${{Postgres.DATABASE_URL}}` | Connection used by migrations. |
| `BASE_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used in share links. Change it if you add a custom domain. |
| `PORT` | `3000` | Port the app listens on. |

Optional features (set them on the Spliit service, see the [upstream README](https://github.com/spliit-app/spliit#readme)): `DEFAULT_CURRENCY_CODE`; receipt images (`ENABLE_EXPENSE_DOCUMENTS` plus `S3_UPLOAD_*`); AI receipt scanning and category suggestions (`ENABLE_RECEIPT_EXTRACT`, `ENABLE_CATEGORY_EXTRACT`, `OPENAI_API_KEY`, optional `OPENAI_BASE_URL`); group deletion (`ENABLE_GROUP_DELETION` plus `CRON_SECRET`); analytics (`ANALYTICS_PROVIDER`).

## Access

Spliit has no user accounts by design: anyone with a group's link can view and edit that group, and anyone who reaches the URL can create a group. Share group links only with the people in them.

## Memory

Runs on Railway's smallest plan (0.5 GB RAM per service). The start script sizes the Node heap to the service's memory limit.

## Updates

This template builds from this repo. When a new Spliit release is pinned here and merged to `main`, Railway shows an "update available" notice on your project and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first; database migrations run automatically on start.

## Local test

```sh
docker compose up --build   # http://localhost:3000
```
