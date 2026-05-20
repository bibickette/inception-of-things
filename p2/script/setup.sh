#!/bin/sh

kubectl delete namespace demo-iot
kubectl create namespace demo-iot

# kubectl expose deployment second-ever --type=ClusterIP --name=second-ever-service --port=4242 --target-port=8080 -n demo-iot
# kubectl expose deployment second-ever --type=LoadBalancer --name=second-ever-loadbalancing --port=4242 --target-port=8080 -n demo-iot

kubectl apply -f baby-pod-dep.yml
kubectl apply -f second-dep.yml
kubectl apply -f three-dep.yml

# kubectl expose deployment first-ever --type=ClusterIP --name=first-ever-service --port=8080 --target-port=8080 -n demo-iot

kubectl apply -f ingress.yml
kubectl describe ingress demo-iot-ingress -n demo-iot