#!/bin/bash

if [[ -z "$NTC_SERVICES_PATH" ]]; then
    echo "Export NTC_SERVICES_PATH before executing this script."
    exit 1
fi

dockerCompose() {
  docker compose -f "$NTC_SERVICES_PATH/compose.yml" --env-file "$NTC_SERVICES_PATH/.env" "$@"
}

certPath=${1:-"cert.pub"}
if [ ! -e "$certPath" ]; then
    echo "Cannot find $certPath!"
fi

if [[ -z "$PROJECT_ID" ]]; then
  export PROJECT_ID=111111
fi

echo "Verifying images..."
for image in $(dockerCompose config | grep -o 'image: .*' | cut -d ' ' -f2); do

  name=$(echo "$image" | cut -d ':' -f1)
  digest="$name@$(docker manifest inspect "$image" -v | jq -r '.Descriptor.digest')"
  if [ -z "$digest" ]; then
    echo "Could not find digest for image: $image"
  elif cosign verify --insecure-ignore-tlog --key "$certPath" "$digest" &>/dev/null; then
    echo "Verified image: $image"
  else
    echo "Unable to verify image: $image"
  fi
done
