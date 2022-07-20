#!/bin/bash

# Setup Vault

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault -n postgres

# Set Kubernetes service account for vault
kubectl create sa postgresql-app -n postgres

# Enable kv-v2 secrets at the path internal
kubectl exec vault-0 -n postgres -- vault secrets enable -path=internal kv-v2

# Create a secret path internal/database/config with
# username, password and database
kubectl exec vault-0 -n postgres -- vault kv put internal/database/config \
    POSTGRES_USER="wach" \
    POSTGRES_PASSWORD="wachemma247" \
    POSTGRES_DB="postgresdb"
        
# Enable the Kubernetes authentication method in vault
kubectl exec vault-0 -- vault auth enable kubernetes

# Configure the Kubernetes authentication method to use the location of the Kubernetes API
kubectl exec vault-0 -n postgres -- vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
                            
# Write out the policy named postgres-app that enables
# the read capability for secrets at path internal/data/database/config
kubectl exec vault-0 -n postgres -- vault policy write postgres-app - <<EOF
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOF

# Create a Kubernetes authentication role named postgres-app
kubectl exec vault-0 -n postgres -- vault write auth/kubernetes/role/postgres-app \
    bound_service_account_names=postgres-app \
    bound_service_account_namespaces=postgres \
    policies=postgres-app \
    ttl=24h
