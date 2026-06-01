#!/bin/sh

apt update 
apt install curl -y

until [ -f /vagrant/.secret/token ]; do
  echo "not found /vagrant/.secret/token"
  sleep 3
done

echo "======== SECRET TOKEN FOLDER FOUNDED ========"
TOKEN=$(cat /vagrant/.secret/token)

curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="$TOKEN" INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111" sh -