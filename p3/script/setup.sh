#!/bin/sh
k3d cluster delete test
k3d cluster create test --port '8888:80@loadbalancer' --port '8080:443@loadbalancer' 

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f /home/iot/inception-of-things/p3/configs/install.yml

echo "Waiting for argocd-server to deploy"

kubectl wait --for=condition=available deployment \
  -l app.kubernetes.io/name=argocd-server \
  -n argocd \
  --timeout=200s

kubectl apply -f /home/iot/inception-of-things/p3/configs/ingress.yml
kubectl apply -f /home/iot/inception-of-things/p3/configs/manifest.yml

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d
echo ""