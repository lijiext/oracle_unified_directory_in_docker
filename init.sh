#!/bin/bash
# -------------------------------------------------------------------------
# IAM Stack Global Initialization Script
# Orchestrates the setup of OUD with REST API support
# -------------------------------------------------------------------------

source .env

# 0. Clean up existing environment
echo "Step 0: Cleaning up existing environment (including volumes)..."
docker compose down -v --remove-orphans

# 1. Start DB
echo "Step 1: Starting Oracle Database (iam-db)..."
docker compose up -d iam-db

# 2. Wait for DB to be healthy
echo "Step 2: Waiting for database (iam-db) to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-db)" == "healthy" ]; do
  echo "Database is still not healthy (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-db)). Waiting..."
  sleep 10
done

# 3. Start OUD
echo "Step 3: Starting OUD (iam-oud)..."
docker compose up -d iam-oud

# 4. Wait for OUD to be healthy
echo "Step 4: Waiting for OUD (iam-oud) to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-oud)" == "healthy" ]; do
  echo "OUD is still not healthy (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-oud)). Waiting..."
  sleep 10
done

# 5. Start OUDSM
echo "Step 5: Starting OUDSM (iam-oudsm)..."
docker compose up -d iam-oudsm

# 6. Wait for OUDSM to be healthy
echo "Step 6: Waiting for OUDSM (iam-oudsm) to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-oudsm)" == "healthy" ]; do
  echo "OUDSM is still not healthy (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-oudsm)). Waiting..."
  sleep 10
done

# 7. Perform deep setup for OUD
echo "Step 7: Performing deep setup for OUD (REST API & ACI)..."
docker exec -it iam-oud /bin/bash /u01/oracle/setup/oud/setup_oud.sh
./scripts/init_oud.sh

# 8. Final start of all components
echo "Step 8: Starting all components..."
docker compose up -d

echo "-----------------------------------------------------------"
echo "OUD REST API Stack is being initialized."
echo "REST Admin API: http://localhost:8444/rest/v1/admin"
echo "REST Data API: https://localhost:1081/rest/v1/directory"
echo "SCIM API: https://localhost:1081/iam/directory/oud/scim/v1"
echo "-----------------------------------------------------------"
