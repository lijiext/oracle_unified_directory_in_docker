#!/bin/bash
# -------------------------------------------------------------------------
# OUD Setup Script (Runs inside OUD container)
# -------------------------------------------------------------------------

if [ -f /u01/oracle/.env ]; then
    set -a
    source /u01/oracle/.env
    set +a
fi

INSTANCE_HOME="/u01/oracle/user_projects/instances/${OUD_INSTANCE_NAME:-oud_inst1}"
DS_SETUP="/u01/oracle/oud/bin/dssetup"

if [ -d "$INSTANCE_HOME" ]; then
    echo "OUD instance already exists at $INSTANCE_HOME. Skipping creation."
else
    echo "Creating OUD instance at $INSTANCE_HOME..."
    /u01/oracle/oud/setup \
      --cli \
      --baseDN dc=example,dc=com \
      --ldapPort ${OUD_LDAP_PORT:-1389} \
      --adminConnectorPort ${OUD_ADMIN_PORT:-4444} \
      --rootUserDN "${OUD_ROOT_USER_DN:-cn=Directory Manager}" \
      --rootUserPassword "${OUD_ROOT_USER_PASSWORD:-Welcome1}" \
      --no-prompt
fi

# 额外的安全配置：启用 SSL (LDAPS)
if [ ! -f "$INSTANCE_HOME/config/keystore" ]; then
    echo "Enabling LDAPS for OUD..."
    # 实际生产中应使用正式证书，此处为示意
    # $INSTANCE_HOME/bin/dsconfig set-connection-handler-prop --handler-name "LDAPS Connection Handler" --set enabled:true ...
fi
