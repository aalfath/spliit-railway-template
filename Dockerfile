# Spliit (https://github.com/spliit-app/spliit), official image, pinned by version and digest.
FROM ghcr.io/spliit-app/spliit:1.30.0@sha256:cfaf0f84ef4f11cd3e4c46329039a0f1f51a7d7bf8cc218bf7c1b366e58a99f1

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    CHECKPOINT_DISABLE=1 \
    PORT=3000

COPY --chmod=0755 railway-start.sh /usr/app/railway-start.sh

EXPOSE 3000
ENTRYPOINT ["/bin/sh", "/usr/app/railway-start.sh"]
