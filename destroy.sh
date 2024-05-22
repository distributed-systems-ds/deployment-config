#!/bin/bash

kubectl patch app todo-microservice-app -p '{"metadata": {"finalizers": ["resources-finalizer.argocd.argoproj.io"]}}' --type merge
kubectl delete app todo-microservice-app

# Delete namespace argocd
kubectl delete namespace argocd