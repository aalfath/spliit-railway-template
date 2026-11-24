# Changelog

## 1.30.0 (2026-11-24)

- First release of the Railway template: Spliit 1.30.0 (`ghcr.io/spliit-app/spliit:1.30.0@sha256:cfaf0f84ef4f11cd3e4c46329039a0f1f51a7d7bf8cc218bf7c1b366e58a99f1`) with Railway Postgres.
- Start script waits for Postgres, runs `prisma migrate deploy`, sets `BASE_URL` from the Railway domain and sizes the Node heap to the memory limit.
