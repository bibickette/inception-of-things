#!/bin/sh
k3d cluster delete test
k3d cluster create test --port '8888:80@loadbalancer' --port 8080:443

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply --server-side --force-conflicts -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable# kubectl apply -k . -n argocd

kubectl apply -k . -n argocd

kubectl apply -f ingress.yml
kubectl apply -f manifest.yml

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d