#!/bin/sh

echo "======== DELETING NAMESPACE AND CLUSTER IF EXIST ========"
kubectl delete namespace argocd
k3d cluster delete wil-app

k3d cluster create wil-app --port '8888:80@loadbalancer' --port '8080:443@loadbalancer'

kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f ./configs/install.yml

echo "Waiting for argocd-server to deploy"
kubectl wait --for=condition=available deployment \
  -l app.kubernetes.io/name=argocd-server \
  -n argocd \
  --timeout=200s

kubectl apply -f ./configs/ingress.yml
kubectl apply -f ./configs/manifest.yml

echo "Password is : "
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d
echo ""