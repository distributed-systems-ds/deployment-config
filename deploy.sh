#!/bin/bash
# Define the namespace name
NAMESPACE="argocd"

# Check if the namespace exists
kubectl get namespace $NAMESPACE
if [ $? -ne 0 ]; then
    echo "Namespace $NAMESPACE does not exist. Creating it now."
    kubectl create namespace argocd
    # Install Argo CD in the namespace
    kubectl apply -n $NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    if [ $? -ne 0 ]; then
        echo "Error creating namespace $NAMESPACE"
        exit 1
    fi

    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n $NAMESPACE --timeout=600s
    kubectl port-forward svc/argocd-server -n $NAMESPACE 9000:443 &
else
    echo "Namespace $NAMESPACE already exists."
fi

# port-forward the Argo CD server
if [ $? -ne 0 ]; then
    echo "Error in port-forwarding the Argo CD server"
    exit 1
fi

echo "Argo CD installation completed successfully."

kubectl apply -f app.yml
if [ $? -ne 0 ]; then
    echo "Error in kubectl apply -f app.yml"
    exit 1
fi
# Path to the folder containing the application files
applications_folder="./applications"

# Apply kubectl apply to all YAML files in the folder
for file in $applications_folder/*.yml; do
    echo "Applying $file ..."
    kubectl apply -f "$file"
    if [ $? -ne 0 ]; then
        echo "Error in kubectl apply -f $file"
        exit 1
    fi
done

# Get argocd password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

#print argocd password
echo "ArgoCD password: $ARGOCD_PASSWORD"

# End of the script
exit 0
