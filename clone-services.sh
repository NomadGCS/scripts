#!/bin/bash
docker run --rm -it -w /home/ntc -v "$(pwd)":/home/ntc \
  -v "$SSH_AUTH_SOCK":/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent bitnami/git \
  git clone https://github.com/NomadGCS/services.git
