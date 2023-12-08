#!/bin/bash

# Ensure that the current user is root
if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root"
  exit 1
fi

commandExists() {
  command -v "$@" >/dev/null 2>&1
}

installDocker() {
    curl -sSL https://get.docker.com | sh
}

installDockerRedHat() {
  DOCKER_INSTALL_INFO='
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/debug-$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://download.docker.com/linux/centos/$releasever/source/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test-debuginfo]
name=Docker CE Test - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/debug-$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://download.docker.com/linux/centos/$releasever/source/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-nightly]
name=Docker CE Nightly - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-nightly-debuginfo]
name=Docker CE Nightly - Debuginfo $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/debug-$basearch/nightly
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-nightly-source]
name=Docker CE Nightly - Sources
baseurl=https://download.docker.com/linux/centos/$releasever/source/nightly
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
'

  echo -e "$DOCKER_INSTALL_INFO" >/etc/yum.repos.d/docker-ce.repo
  dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --allowerasing -y
}

if [ -e "/etc/redhat-release" ]; then
  if commandExists docker; then
    echo "Docker already installed"
  else
    echo "Ensure that RedHat is registered with the subscription server:"
    echo -e "  \e[37msubscription-manager register --username <username> --password <password> --auto-attach\e[0m"
    echo
    echo "Continuing install in 5 seconds. ^C to cancel"
    for ((i = 5; i > 0; i--)); do
    echo -e "\e[1A\e[Continuing install in $i seconds. ^C to cancel"
      sleep 1
    done
    echo -e "\e[1A\e[K"
    echo
    installDockerRedHat
  fi
else
  installDocker
fi
