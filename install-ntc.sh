#!/bin/bash
# shellcheck disable=SC2154

readInput() {
  local name="$1"
  local currentValue="${!name:-$2}"
  read -rp "Enter the $name [current: $currentValue]: " inputValue
  eval "$name=\"${inputValue:-$currentValue}\""
}

updateOrReplaceEnvVar() {

  local name="$1"
  local value=${!name}
  eval "export $name"
  if grep -q "^$name=" /etc/environment; then
      sed -i "s|^$name=.*$|$name=$value|" /etc/environment
  else
      echo "$name=$value" | tee -a /etc/environment
  fi
}

# Read inputs for paths and version
readInput "version" "latest"
readInput "NTC_SERVICES_PATH" "$(pwd)/services"
readInput "NTC_CONFIG_PATH" "$(pwd)/configurations"

# Export the paths for system use and make them persistent
mkdir -p "$NTC_CONFIG_PATH" "$NTC_SERVICES_PATH"
updateOrReplaceEnvVar "NTC_CONFIG_PATH"
updateOrReplaceEnvVar "NTC_SERVICES_PATH"
# Install Docker by downloading and running the script from this repo
curl -sSL https://raw.githubusercontent.com/NomadGCS/scripts/main/install-docker.sh | sh
# Clone the services repository
if [[ -n $SSH_AUTH_SOCK ]]; then
  docker run --rm -it -w /app -v "$NTC_SERVICES_PATH:/app" \
    -v "$SSH_AUTH_SOCK":/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent bitnami/git \
    git clone -b "$version" https://github.com/NomadGCS/services.git /app
else
  docker run --rm -it -w /app -v "$NTC_SERVICES_PATH:/app" bitnami/git \
    git clone -b "$version" https://github.com/NomadGCS/services.git /app
fi
# Create a command using the ntc script
chmod -R a+x "$NTC_SERVICES_PATH/scripts"
cp -fp "$NTC_SERVICES_PATH/scripts/ntc.sh" /usr/local/bin/ntc
cp -np "$NTC_SERVICES_PATH/.env" "$NTC_CONFIG_PATH/.env"
cp -np "$NTC_SERVICES_PATH/.env" "$NTC_CONFIG_PATH/.env"

echo
echo "Installation complete. Use the \`ntc\` command moving forward."
ntc 2>/dev/null
echo
