#!/bin/sh

kubectl delete namespace demo-iot
kubectl create namespace demo-iot

# kubectl expose deployment app2 --type=ClusterIP --name=app2-service --port=4242 --target-port=8080 -n demo-iot
# kubectl expose deployment app2 --type=LoadBalancer --name=app2-loadbalancing --port=4242 --target-port=8080 -n demo-iot

kubectl apply -f app1.yml
kubectl apply -f app2.yml
kubectl apply -f app3.yml

# kubectl expose deployment app1 --type=ClusterIP --name=app1-service --port=8080 --target-port=8080 -n demo-iot

kubectl apply -f ingress.yml
kubectl describe ingress demo-iot-ingress -n demo-iot