#!/bin/sh

if [ -f /vagrant/.secret/token ]
then
  echo "======== DELETING SECRET TOKEN FOLDER ========"
  rm -rf /vagrant/.secret
fi

apt update 
apt install curl -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110" sh -

# Get the token for the worker nodes
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

echo "======== CREATING SECRET TOKEN FOLDER ========"
mkdir -p /vagrant/.secret

# Store the token for the workers to use
echo $TOKEN > /vagrant/.secret/token