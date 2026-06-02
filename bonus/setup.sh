#!/bin/sh

echo "======== DELETING NAMESPACE IF EXISTS ========"
kubectl delete pod -n gitlab --all
kubectl delete namespace gitlab

echo "======== CREATING NAMESPACE IF NOT EXISTS ========"
kubectl create namespace gitlab

kubectl -n gitlab create secret generic psql-password \
  --from-literal=password='TonMotDePassePostgres'

helm install gitlab gitlab/gitlab -n gitlab -f custom-values.yml