#!/bin/sh
apt update 
apt install curl -y
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110" sh -

# Get the token for the worker nodes
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
mkdir /vagrant/.secret
# Store the token for the workers to use
echo $TOKEN > /vagrant/.secret/token