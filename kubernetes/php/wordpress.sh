#!/bin/bash
kubectl config set-context --current --namespace=wordpress
#curl -LO https://k8s.io/examples/application/wordpress/mysql-deployment.yaml
#curl -LO https://k8s.io/examples/application/wordpress/wordpress-deployment.yaml

kubectl apply -f mysql-deployment.yaml
kubectl apply -f wordpress-deployment.yaml


