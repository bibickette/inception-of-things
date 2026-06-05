#!/bin/sh

echo "======== DELETING NAMESPACE IF EXISTS ========"
helm uninstall -n gitlab gitlab
kubectl delete namespace gitlab

echo "======== INSTALLING GITLAB ... ========"

helm upgrade --install gitlab ./gitlab --namespace gitlab --create-namespace --wait

GITLAB_POD_NAME=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=gitlab -o jsonpath={.items[0].metadata.name})
kubectl exec -n gitlab $GITLAB_POD_NAME -- cat /etc/gitlab/initial_root_password
