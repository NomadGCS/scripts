#!/bin/bash
# Read the current input
servicesPath="${NTC_SERVICES_PATH:-$(pwd)/services}"
read -r -p "Enter the directory for NTC services [current: $servicesPath]: " inputValue
if [[ -n "$inputValue" ]]; then
  servicesPath="$inputValue"
fi

version="latest"
read -r -p "Enter the NTC version [default: $version]: " inputValue
if [[ -n "$inputValue" ]]; then
  version="$inputValue"
fi
# Export the path for system use and make it persistent
mkdir -p "$servicesPath"
NTC_SERVICES_PATH="$servicesPath"
export NTC_SERVICES_PATH
if grep -q "^NTC_SERVICES_PATH=" /etc/environment; then
    sed -i "s|^NTC_SERVICES_PATH=.*$|NTC_SERVICES_PATH=$NTC_SERVICES_PATH|" /etc/environment
else
    echo "NTC_SERVICES_PATH=$NTC_SERVICES_PATH" | tee -a /etc/environment
fi
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
echo "Installation complete. Use the \`ntc\` command moving forward."
ntc 2>/dev/null
