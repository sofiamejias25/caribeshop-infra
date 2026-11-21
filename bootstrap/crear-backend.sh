#!/usr/bin/env bash
# Crea el Storage del estado remoto de Terraform (se corre una sola vez).
set -euo pipefail

RG="cs-tfstate-rg"
LOC="chilecentral"
SA="cstfstate$RANDOM"
CONT="tfstate"

az group create -n "$RG" -l "$LOC" -o none

az storage account create -n "$SA" -g "$RG" -l "$LOC" \
  --sku Standard_LRS --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --allow-shared-key-access false -o none

az role assignment create \
  --assignee "$(az ad signed-in-user show --query id -o tsv)" \
  --role "Storage Blob Data Contributor" \
  --scope "$(az storage account show -n "$SA" -g "$RG" --query id -o tsv)" -o none

az storage account blob-service-properties update \
  --account-name "$SA" -g "$RG" \
  --enable-versioning true \
  --enable-delete-retention true --delete-retention-days 7 -o none

echo "Esperando 60 s a que el permiso se propague..."
sleep 60

az storage container create -n "$CONT" --account-name "$SA" --auth-mode login -o none

echo "Listo. Nombre del Storage: $SA"