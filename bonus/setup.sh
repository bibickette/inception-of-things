#!/bin/sh

echo "======== DELETING NAMESPACE IF EXISTS ========"
kubectl delete pod -n gitlab --all
kubectl delete namespace gitlab

echo "======== CREATING NAMESPACE IF NOT EXISTS ========"
kubectl create namespace gitlab

helm upgrade --install gitlab ./gitlab --namespace gitlab --create-namespace --wait
kubectl wait --for=condition=available deployment/gitlab \
  -l app.kubernetes.io/name=gitlab  \
  -n gitlab \
  --timeout=600s

echo "Password is : "
GITLAB_POD_NAME=$$(kubectl get pods -n gitlab -l app.kubernetes.io/name=gitlab -o jsonpath={.items[0].metadata.name})
kubectl exec -n gitlab $GITLAB_POD_NAME -- cat /etc/gitlab/initial_root_password
echo ""