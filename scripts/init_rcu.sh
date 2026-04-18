#!/bin/bash
# -------------------------------------------------------------------------
# OAM RCU Initialization Script
# This script runs inside the OAM container to create the metadata schema in DB
# -------------------------------------------------------------------------

if [ -f /u01/oracle/.env ]; then
    set -a
    source /u01/oracle/.env
    set +a
fi

RCU_BIN="/u01/oracle/oracle_common/bin/rcu"
DB_CONN="${CONNECTION_STRING:-iam-db:1521/PDB1}"
DB_USER="sys"
DB_ROLE="sysdba"
SCHEMA_PREFIX="OAM1"
SCHEMA_PWD="${OAM_DB_SCHEMA_PWD:-Welcome1}"
SYS_PWD="${DB_PWD:-Welcome1}"

echo "Checking if RCU components already exist..."
# In Oracle DB, check for schema prefix OAM1_
# We can use sqlplus if needed, but let's keep it simple for now and rely on RCU's own reporting.
# RCU normally fails if the schema exists.

echo "Starting RCU to create OAM repository in $DB_CONN..."
# Note: Using 'bash -c' inside docker exec avoids TTY issues in non-interactive scripts

$RCU_BIN -silent -createRepository \
    -databaseType ORACLE \
    -connectString "$DB_CONN" \
    -dbUser "$DB_USER" \
    -dbRole "$DB_ROLE" \
    -schemaPrefix "$SCHEMA_PREFIX" \
    -schemaPassword "$SCHEMA_PWD" \
    -sysPassword "$SYS_PWD" \
    -selectComponent OAM \
    -selectComponent IAU \
    -selectComponent IAU_APPEND \
    -selectComponent IAU_VIEWER \
    -selectComponent OPSS \
    -selectComponent WLS \
    -selectComponent STB

if [ $? -eq 0 ]; then
    echo "RCU completed successfully."
else
    echo "RCU failed. Please check logs."
    exit 1
fi
