#!/usr/bin/env nim
mode = ScriptMode.Silent
switch("hints", "off")

from strutils import parseBool

## Whether to push a fresh app binary to be used in this example.
let fresh = paramStr(paramCount()).parseBool
if fresh: exec "bash tasks/debug-docker-build.sh example"

## Build Docker Image Example.
exec """
docker \
  build \
    --no-cache \
    --progress plain \
    --build-arg UID=9234 \
    --build-arg GID=9432 \
    -t test/gitea:1.16.5-linux-amd64-rootless \
    -f tests/gitea.Dockerfile \
  .
"""

## Delete all Docker Image Examples, safely.
exec """docker image prune --force --all --filter "label=testuserdef""""