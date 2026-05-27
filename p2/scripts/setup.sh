#!/bin/sh

kubectl delete namespace app-iot
kubectl create namespace app-iot

kubectl apply -f app1.yml
kubectl apply -f app2.yml
kubectl apply -f app3.yml

kubectl apply -f ingress.yml
kubectl describe ingress app-iot-ingress -n app-iot