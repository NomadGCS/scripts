#!/bin/bash
docker run --rm -it -w /home/ntc/services -v "$(pwd)":/home/ntc/services \
  -v "$SSH_AUTH_SOCK":/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent bitnami/git \
  git pull --tags
