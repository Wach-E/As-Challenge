#!/bin/bash

# Setup Vault

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault -n postgres

# Set Kubernetes service account for vault
kubectl create sa postgres-app -n postgres


# Initialize and useal vault
kubectl exec -ti vault-0 -n postgres -- vault operator init
kubectl exec -ti vault-0 -n postgres -- vault operator unseal <Key1>
kubectl exec -ti vault-0 -n postgres -- vault operator unseal <Key2>
kubectl exec -ti vault-0 -n postgres -- vault operator unseal <Key3>

N/B: Make sure to save the 5 keys and Initial Root Token.

# Login to vault
kubectl exec -ti vault-0 -n postgres -- vault login

# Enable kv-v2 secrets at the path internal
kubectl exec -ti vault-0 -n postgres -- vault secrets enable -path=internal kv-v2

# Create a secret path internal/database/config with
# username, password and database
kubectl exec -ti vault-0 -n postgres -- vault kv put internal/database/config \
    POSTGRES_USER="wach" \
    POSTGRES_PASSWORD="wachemma247" \
    POSTGRES_DB="postgresdb"
        
# Enable the Kubernetes authentication method in vault
kubectl exec -ti vault-0 -n postgres -- vault auth enable kubernetes

# Setup Vault authorizations for Kubernetes 
TOKEN_REVIEW_JWT=$(kubectl get secret postgres-app-secret -n postgres -o go-template='{{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.server}')

# Configure the Kubernetes authentication method to use the location of the Kubernetes API
kubectl exec -ti vault-0 -n postgres -- vault write auth/kubernetes/config \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT" \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    disable_local_ca_jwt="true"
    
# Confirm vault authorization with Kubernetes
kubectl exec -ti vault-0 -n postgres -- vault read auth/kubernetes/config
                            
# Write out the policy named postgres-app that enables
# the read capability for secrets at path internal/data/database/config
kubectl exec -ti vault-0 -n postgres -- vault policy write postgres-app - <<EOF
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOF

# Create a Kubernetes authentication role named postgres-app
kubectl exec -ti vault-0 -n postgres -- vault write auth/kubernetes/role/postgres-app \
    bound_service_account_names=postgres-app \
    bound_service_account_namespaces=postgres \
    policies=postgres-app \
    ttl=24h
