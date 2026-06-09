#!/bin/sh

echo "======== DELETING CLUSTER & NAMESPACE ========"
helm uninstall -n gitlab gitlab
kubectl delete namespace gitlab
k3d cluster delete lab

echo "======== CREATING K3D Cluster ========"
k3d cluster create lab --port '8888:80@loadbalancer' --port '8080:443@loadbalancer' \
    --volume /mnt/gitlab-data:/mnt/gitlab-data \
    --volume /mnt/postgresql-data:/mnt/postgresql-data

echo "======== CREATING ARGOCD namespace and server ========"
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f /home/iot/inception-of-things/bonus/configs/install.yml

echo "Waiting for argocd-server to deploy"
kubectl wait --for=condition=available deployment \
  -l app.kubernetes.io/name=argocd-server \
  -n argocd \
  --timeout=200s

kubectl apply -f /home/iot/inception-of-things/bonus/configs/ingress.yml
kubectl apply -f /home/iot/inception-of-things/bonus/configs/secret_gitlab.yml

echo "======== Password for argocd.localhost is in pass_argocd.key"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath={.data.password} | base64 -d > pass_argocd.key

echo "======== INSTALLING GITLAB ... ========"

helm upgrade --install gitlab ./gitlab --namespace gitlab --create-namespace --wait --timeout 10m

echo "======== Password for gitlab.localhost is in pass_gitlab.key"
GITLAB_POD_NAME=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=gitlab -o jsonpath={.items[0].metadata.name})
kubectl exec -n gitlab $GITLAB_POD_NAME -- cat /etc/gitlab/initial_root_password > pass_gitlab.key

kubectl apply -f /home/iot/inception-of-things/bonus/configs/manifest_gitlab.yml


