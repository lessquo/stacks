#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$REPO_ROOT/backends"

# Only the web starter; DB/migration/validation/springdoc deps are added to
# build.gradle.kts in later phases.
docker run --rm \
  -v "$REPO_ROOT/backends":/work \
  -w /work \
  alpine:3.21 \
  sh -c "apk add --quiet --no-cache curl unzip \
         && curl -fsSL https://start.spring.io/starter.zip \
              -d type=gradle-project-kotlin \
              -d language=kotlin \
              -d javaVersion=21 \
              -d groupId=dev.stacks \
              -d artifactId=kotlin-spring \
              -d name=kotlin-spring \
              -d packageName=dev.stacks \
              -d dependencies=web \
              -d baseDir=kotlin-spring \
              -o starter.zip \
         && unzip -q starter.zip \
         && rm starter.zip"
