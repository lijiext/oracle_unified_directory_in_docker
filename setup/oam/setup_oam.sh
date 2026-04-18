#!/bin/bash
# -------------------------------------------------------------------------
# OAM Domain Setup Script (Runs inside OAM container)
# -------------------------------------------------------------------------

if [ -f /u01/oracle/.env ]; then
    set -a
    source /u01/oracle/.env
    set +a
fi

DOMAIN_HOME="/u01/oracle/user_projects/domains/${OAM_DOMAIN:-oam_domain}"
WLST="/u01/oracle/oracle_common/common/bin/wlst.sh"

# 检查 Admin Server 是否已启动
echo "Checking if Admin Server is already running..."
max_retries=10
count=0
while ! curl -s http://localhost:7001/console > /dev/null; do
    echo "Waiting for Admin Server to respond... ($count/$max_retries)"
    sleep 30
    count=$((count + 1))
    if [ $count -ge $max_retries ]; then
        echo "Admin Server failed to respond. Please check OAM container logs."
        exit 1
    fi
done
echo "Admin Server is up and running."

# 执行 OAM-OUD 集成配置
echo "Configuring OUD as Identity Store..."
$WLST /u01/oracle/setup/oam/config_oud_integration.py
