#!/bin/bash
# -------------------------------------------------------------------------
# IAM Stack Global Initialization Script
# Orchestrates the setup of OUD, DB RCU, OAM, and OHS
# -------------------------------------------------------------------------

source .env

# 1. Start core infra
echo "Step 1: Starting core infrastructure (DB, OUD, OUDSM)..."
docker compose up -d iam-db iam-oud iam-oudsm

# 2. Wait for DB to be healthy
echo "Step 2: Waiting for database (iam-db) to be healthy..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-db)" == "healthy" ]; do
  echo "Database is still not healthy (current status: $(docker inspect -f '{{.State.Health.Status}}' iam-db)). Waiting..."
  sleep 10
done

# 3. Wait for OUD and import data
echo "Step 3: Performing deep setup for OUD..."
docker exec -it iam-oud /bin/bash /u01/oracle/setup/oud/setup_oud.sh
./scripts/init_oud.sh

# 4. Start OAM container (to access RCU tool)
echo "Step 4: Starting OAM container for RCU creation..."
docker compose up -d iam-oam

# Wait for OAM container to be ready for RCU
sleep 10

# 5. Run RCU to create schemas
echo "Step 5: Running RCU inside iam-oam..."
docker exec -it iam-oam /bin/bash /u01/oracle/scripts/init_rcu.sh

# 6. Deep setup of OAM Domain and Integration
echo "Step 6: Performing deep setup for OAM (Domain Creation & Integration)..."
docker exec -it iam-oam /bin/bash /u01/oracle/setup/oam/setup_oam.sh

# 7. Start OHS container
echo "Step 7: Starting OHS container..."
docker compose up -d iam-ohs
sleep 10

# 8. Deep setup of OHS Instance
echo "Step 8: Performing deep setup for OHS (Instance Creation & WebGate)..."
docker exec -it iam-ohs /bin/bash /u01/oracle/setup/ohs/setup_ohs.sh

# 9. Final start of all components
echo "Step 9: Starting all components..."
docker compose up -d

echo "-----------------------------------------------------------"
echo "IAM Stack is being initialized. Check logs for progress:"
echo "docker-compose logs -f iam-oam"
echo "-----------------------------------------------------------"
