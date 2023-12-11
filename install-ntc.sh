#!/bin/bash
# Read the current input
servicesPath="${NTC_SERVICES_PATH:-$(pwd)/services}"
read -r -p "Enter the directory for NTC services [current: $servicesPath]: " inputValue
if [[ -n "$inputValue" ]]; then
  servicesPath="$inputValue"
fi

branch="main"
read -r -p "Enter the services branch [default: $branch]: " inputValue
if [[ -n "$inputValue" ]]; then
  branch="$inputValue"
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
# Clone the services directory
docker run --rm -it -w /app -v "$NTC_SERVICES_PATH:/app" \
  -v "$SSH_AUTH_SOCK":/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent bitnami/git \
  git clone --branch "$branch" https://github.com/NomadGCS/services.git /app
chmod -R a+x "$NTC_SERVICES_PATH/scripts"
# Create a command using the ntc script
cp -fp "$NTC_SERVICES_PATH/scripts/ntc.sh" /usr/local/bin/ntc
echo "Installation complete. Use the \`ntc\` command moving forward."
ntc
