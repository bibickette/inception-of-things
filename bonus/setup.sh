#!/bin/sh
set -eu

CLUSTER_NAME="lab"
GITLAB_NS="gitlab"
ARGOCD_NS="argocd"

GITLAB_DATA="/mnt/gitlab-data"
POSTGRES_DATA="/mnt/postgresql-data"

install() {
  echo "======== CREATING K3D Cluster ========"
  k3d cluster create "$CLUSTER_NAME" \
    --port '8888:80@loadbalancer' \
    --port '8080:443@loadbalancer' \
    --volume ${GITLAB_DATA}:/mnt/gitlab-data \
    --volume ${POSTGRES_DATA}:/mnt/postgresql-data

  echo "======== CREATING ARGOCD namespace and server ========"
  kubectl create namespace "$ARGOCD_NS" || true
  kubectl apply -n "$ARGOCD_NS" --server-side --force-conflicts -f ./configs/install.yml

  echo "Waiting for argocd-server to deploy"
  kubectl wait --for=condition=available deployment \
    -l app.kubernetes.io/name=argocd-server \
    -n "$ARGOCD_NS" \
    --timeout=200s

  kubectl apply -f ./configs/ingress.yml
  kubectl apply -f ./configs/secret_gitlab.yml

  echo "======== Password for argocd.localhost is in pass_argocd.key"
  kubectl get secret argocd-initial-admin-secret -n "$ARGOCD_NS" -o jsonpath='{.data.password}' | base64 -d > pass_argocd.key

  echo "======== INSTALLING GITLAB ... ========"
  helm upgrade --install gitlab ./gitlab --namespace "$GITLAB_NS" --create-namespace --wait --timeout 10m

  echo "======== Password for gitlab.localhost is in pass_gitlab.key"
  if [ ! -f "pass_gitlab.key" ]; then
    GITLAB_POD_NAME=$(kubectl get pods -n "$GITLAB_NS" -l app.kubernetes.io/name=gitlab -o jsonpath='{.items[0].metadata.name}')
    kubectl exec -n "$GITLAB_NS" "$GITLAB_POD_NAME" -- cat /etc/gitlab/initial_root_password > pass_gitlab.key
  fi

  kubectl apply -f ./configs/manifest_gitlab.yml
}

uninstall() {
  echo "======== DELETING GITLAB ========"
  helm uninstall -n "$GITLAB_NS" gitlab || true
  kubectl delete namespace "$GITLAB_NS" --ignore-not-found=true

  echo "======== DELETING ARGOCD ========"
  kubectl delete -f ./configs/manifest_gitlab.yml --ignore-not-found=true || true
  kubectl delete -f ./configs/secret_gitlab.yml --ignore-not-found=true || true
  kubectl delete -f ./configs/ingress.yml --ignore-not-found=true || true
  kubectl delete namespace "$ARGOCD_NS" --ignore-not-found=true

  echo "======== DELETING CLUSTER ========"
  k3d cluster delete "$CLUSTER_NAME" || true
}

prune() {
  uninstall
  echo "======== DELETING DATA VOLUMES ========"
  sudo rm -rf "$GITLAB_DATA" "$POSTGRES_DATA"
  rm pass_*.key
}

case "${1:-}" in
  install) install ;;
  uninstall) uninstall ;;
  reinstall) uninstall; install ;;
  prune) prune ;;
  *)
    echo "Usage: $0 {install|uninstall|reinstall|prune}"
    exit 1
    ;;
esac