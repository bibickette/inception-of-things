#!/bin/sh

echo "======== DELETING CLUSTER & NAMESPACE ========"
helm uninstall -n gitlab gitlab
kubectl delete namespace gitlab
k3d cluster delete lab

echo "======== CREATING K3D Cluster ========"
k3d cluster create lab --port '8888:80@loadbalancer' --port '8080:443@loadbalancer' --volume /mnt/gitlab-data:/mnt/gitlab-data --volume /mnt/postgresql-data:/mnt/postgresql-data


echo "======== INSTALLING GITLAB ... ========"

helm upgrade --install gitlab ./gitlab --namespace gitlab --create-namespace --wait

GITLAB_POD_NAME=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=gitlab -o jsonpath={.items[0].metadata.name})
kubectl exec -n gitlab $GITLAB_POD_NAME -- cat /etc/gitlab/initial_root_password
