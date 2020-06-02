#!/bin/bash


#wget https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
#wget https://k8s.io/examples/application/guestbook/redis-master-service.yaml
#wget https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml 
#wget https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
#wget https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
#wget https://k8s.io/examples/application/guestbook/frontend-service.yaml 

kubectl config set-context --current --namespace=phpgestbook
kubectl delete -f frontend-deployment.yaml
sleep 10s
kubectl apply -f frontend-deployment.yaml


kubectl apply -f redis-master-deployment.yaml
kubectl apply -f redis-master-service.yaml
kubectl apply -f redis-slave-deployment.yaml 
kubectl apply -f redis-slave-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml 

