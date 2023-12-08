#!/bin/bash
docker run --rm -it -w /app -v "$NTC_SERVICES_PATH:/app" \
  -v "$SSH_AUTH_SOCK":/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent bitnami/git \
  git clone https://github.com/NomadGCS/services.git
