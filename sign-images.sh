#!/bin/bash

if [[ -z "$NTC_SERVICES_PATH" ]]; then
    echo "Export NTC_SERVICES_PATH before executing this script."
    exit 1
fi

dockerCompose() {
  docker compose -f "$NTC_SERVICES_PATH/compose.yml" --env-file "$NTC_SERVICES_PATH/.env" "$@"
}

certPath=${1:-"cert.key"}
passPath=${2:-".pass"}
if [ ! -e "$certPath" ]; then
    echo "Cannot find $certPath!"
fi

if [[ -z "$PROJECT_ID" ]]; then
  export PROJECT_ID=111111
fi

echo "Signing images..."
for image in $(dockerCompose config | grep -o 'image: .*' | cut -d ' ' -f2); do

  name=$(echo "$image" | cut -d ':' -f1)
  digest="$name@$(docker manifest inspect "$image" -v | jq -r '.Descriptor.digest')"
  if [ -z "$digest" ]; then
    echo "Could not find digest for image: $image"
  else
    echo "Signing $image..."
    cosign sign --key="$certPath" --tlog-upload=false "$digest" < "$passPath"
  fi
done
echo "Signed all images."
