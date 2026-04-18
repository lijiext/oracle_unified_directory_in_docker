#!/bin/bash
# -------------------------------------------------------------------------
# IAM Stack Global Initialization Script
# Orchestrates the setup of OUD, DB RCU, OAM, and OHS
# -------------------------------------------------------------------------

source .env

# 0. Clean up existing environment
echo "Step 0: Cleaning up existing environment (including volumes)..."
docker compose down -v --remove-orphans
rm -rf ./ohs_boot

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
echo "Step 7: Performing deep setup for OUD..."
docker exec -it iam-oud /bin/bash /u01/oracle/setup/oud/setup_oud.sh
./scripts/init_oud.sh

# 8. Start OAM container
echo "Step 8: Starting OAM container (Automatic RCU & Domain Creation)..."
docker compose up -d iam-oam

# 9. Wait for OAM to be healthy
echo "Step 9: Waiting for OAM (iam-oam) to be healthy (this may take several minutes)..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-oam)" == "healthy" ]; do
  echo "OAM is still initializing (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-oam)). Waiting..."
  sleep 30
done

# 10. Perform deep setup for OAM Integration
echo "Step 10: Performing deep setup for OAM Integration..."
docker exec -it iam-oam /bin/bash /u01/oracle/setup/oam/setup_oam.sh

# 11. Start OHS container
echo "Step 11: Starting OHS container (Automatic Instance Creation)..."
mkdir -p ./ohs_boot
cat <<EOF > ./ohs_boot/domain.properties
username=weblogic
password=${OHS_ADMIN_PWD:-Welcome1}
EOF
docker compose up -d iam-ohs

# 12. Wait for OHS to be healthy
echo "Step 12: Waiting for OHS (iam-ohs) to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-ohs)" == "healthy" ]; do
  echo "OHS is still initializing (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-ohs)). Waiting..."
  sleep 20
done

# 13. Perform deep setup for OHS (WebGate, etc.)
echo "Step 13: Performing deep setup for OHS (WebGate Integration)..."
docker exec -it iam-ohs /bin/bash /u01/oracle/setup/ohs/setup_ohs.sh

# 13. Final start of all components
echo "Step 13: Starting all components..."
docker compose up -d

echo "-----------------------------------------------------------"
echo "IAM Stack is being initialized. Check logs for progress:"
echo "docker-compose logs -f iam-oam"
echo "-----------------------------------------------------------"
