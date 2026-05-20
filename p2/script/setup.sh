#!/bin/sh

kubectl create namespace demo-iot
kubectl apply -f second-dep.yml
kubectl expose deployment second-ever --type=ClusterIP --name=second-ever-service --port=4242 --target-port=8080 -n demo-iot
kubectl expose deployment second-ever --type=LoadBalancer --name=second-ever-loadbalancing --port=4242 --target-port=8080 -n demo-iot