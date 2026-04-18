#!/bin/bash
# -------------------------------------------------------------------------
# OUD Data Import Script
# This script runs outside the OUD container to import LDIF files
# -------------------------------------------------------------------------

# Get script directory to find .env correctly
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
source "$PROJECT_ROOT/.env"

OUD_HOST="localhost"
OUD_PORT="${OUD_LDAP_PORT:-1389}"
ADMIN_DN="${OUD_ROOT_DN:-cn=Directory Manager}"
ADMIN_PWD="${OUD_PWD:-Welcome1}"

echo "Checking if OUD is up on $OUD_HOST:$OUD_PORT..."
# Wait for LDAP to respond
until docker exec iam-oud /u01/oracle/oud/bin/ldapsearch -h localhost -p 1389 -D "$ADMIN_DN" -w "$ADMIN_PWD" -b "" -s base "objectclass=*" > /dev/null 2>&1; do
  echo "OUD LDAP is still not ready. Waiting..."
  sleep 5
done

echo "Importing LDIF files..."
for f in ldif/*.ldif; do
  echo "Processing $f..."
  docker exec -i iam-oud /u01/oracle/oud/bin/ldapmodify -h localhost -p 1389 -D "$ADMIN_DN" -w "$ADMIN_PWD" -a < "$f"
done

echo "OUD Initialization completed."
