﻿FROM rclone/rclone:latest as rclone-stage
#FROM spoked/riven-frontend:latest as frontend-stage

FROM python:3.11-alpine
COPY --from=rclone-stage /usr/local/bin/rclone /usr/local/bin/rclone
#COPY --from=frontend-stage /riven /riven/frontend

WORKDIR /

ADD . / ./
ADD https://raw.githubusercontent.com/debridmediamanager/zurg-testing/main/config.yml /zurg/
ADD https://raw.githubusercontent.com/debridmediamanager/zurg-testing/main/plex_update.sh /zurg/

ENV \
  XDG_CONFIG_HOME=/config \
  TERM=xterm

RUN \
  apk add --update --no-cache gcompat libstdc++ libxml2-utils curl tzdata nano ca-certificates wget fuse3 build-base linux-headers py3-cffi libffi-dev rust cargo openssl openssl-dev pkgconfig git npm ffmpeg && \
  npm install -g pnpm && \
  mkdir /log && \
  python3 -m venv /venv && \
  source /venv/bin/activate && \
  pip install --upgrade pip && \
  pip install -r /requirements.txt

HEALTHCHECK --interval=60s --timeout=10s \
  CMD ["/bin/sh", "-c", "source /venv/bin/activate && python /healthcheck.py"]

ENTRYPOINT ["/bin/sh", "-c", "source /venv/bin/activate && python /main.py"]
