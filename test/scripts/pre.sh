#!/usr/bin/env bash

set -ex

HELMVERSION=$1
if [[ "${HELMVERSION}" == "" ]]; then
    HELMVERSION="helm-v3.0.0"
fi

MINIKUBEVERESION=$2
if [[ "${MINIKUBEVERESION}" == "" ]]; then
    MINIKUBEVERESION="minikube-v1.8.0"
fi

K8SVERSION=$3
if [[ "${K8SVERSION}" == "" ]]; then
    K8SVERSION="k8s-v1.15.4"
fi

# Remove strict host checking. The rest of the file is already populated by the 'add_ssh_keys' step.
mkdir -p ~/.ssh
echo -e "\tStrictHostKeyChecking no" >> ~/.ssh/config
echo -e "\tControlMaster auto" >> ~/.ssh/config
echo -e "\tControlPersist 3600" >> ~/.ssh/config
echo -e "\tControlPath ~/.ssh/%r@%h:%p" >> ~/.ssh/config

# Create directory for logs.
mkdir -p ~/logs

# create directory for e2e artifacts.
mkdir -p ~/pipeline-craft/test/e2e/artifacts

curl -sSL https://get.helm.sh/${HELMVERSION}-linux-amd64.tar.gz | \
    sudo tar xz -C /usr/local/bin --strip-components=1 linux-amd64/helm

sudo mkdir -p /usr/local/bin
curl -sSL "https://storage.googleapis.com/minikube/releases/${MINIKUBEVERESION#minikube-}/minikube-linux-amd64" -o /tmp/minikube
chmod +x /tmp/minikube
sudo mv /tmp/minikube /usr/local/bin/minikube

curl -sSL "https://storage.googleapis.com/kubernetes-release/release/${K8SVERSION#k8s-}/bin/linux/amd64/kubectl" -o /tmp/kubectl
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin/kubectl

sudo apt-get remove -y --purge man-db
sudo apt-get update
sudo apt-get install -y \
    --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages \
    xvfb libgtk-3-0 libnotify4 libgconf-2-4 libnss3 libxss1 libasound2 \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    openjdk-8-jdk-headless
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-cache madison docker-ce
sudo apt-get install -y docker-ce=5:19.03.8~3-0~ubuntu-xenial docker-ce-cli=5:19.03.8~3-0~ubuntu-xenial containerd.io
