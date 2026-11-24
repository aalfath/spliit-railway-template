#!/bin/sh
# Railway wrapper for Spliit: waits for Postgres, runs the Prisma migrations
# (Prisma takes its own advisory lock, so overlapping deploys are safe), sizes
# the Node heap to the service's memory limit, then starts the Next.js server.
# Any failure exits non-zero so Railway's ON_FAILURE restart policy applies.
set -eu
cd /usr/app

# Both URLs default to each other, so one DATABASE_URL-style reference is enough.
: "${POSTGRES_PRISMA_URL:=${POSTGRES_URL_NON_POOLING:-${DATABASE_URL:-}}}"
: "${POSTGRES_URL_NON_POOLING:=$POSTGRES_PRISMA_URL}"
if [ -z "$POSTGRES_PRISMA_URL" ]; then
  echo "railway-start: POSTGRES_PRISMA_URL is not set (expected \${{Postgres.DATABASE_URL}})" >&2
  exit 1
fi
export POSTGRES_PRISMA_URL POSTGRES_URL_NON_POOLING

# Public URL: Railway's domain unless BASE_URL is set explicitly.
if [ -z "${BASE_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export BASE_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

# Next.js standalone binds to $HOSTNAME; Docker may set it to the container id.
export HOSTNAME=0.0.0.0
export PORT="${PORT:-3000}"

# Node heap: about 60% of the cgroup memory limit, between 128 and 1024 MB.
limit=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
if [ "$limit" != "max" ] && [ "$limit" -gt 0 ] 2>/dev/null; then
  heap=$((limit / 1048576 * 60 / 100))
  [ "$heap" -lt 128 ] && heap=128
  [ "$heap" -gt 1024 ] && heap=1024
  case " ${NODE_OPTIONS:-} " in *max-old-space-size*) ;; *) export NODE_OPTIONS="${NODE_OPTIONS:-} --max-old-space-size=$heap" ;; esac
fi

# Railway's private DNS and a fresh Postgres can take a minute on first deploy.
i=1
until node node_modules/prisma/build/index.js migrate deploy; do
  if [ "$i" -ge 30 ]; then
    echo "railway-start: database migrations failed after $i attempts" >&2
    exit 1
  fi
  echo "railway-start: database not ready (attempt $i of 30), retrying in 5s" >&2
  i=$((i + 1))
  sleep 5
done

exec node server.js
