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

if [ -d "$DOMAIN_HOME" ]; then
    echo "Domain already exists at $DOMAIN_HOME. Skipping creation."
else
    echo "Creating OAM Domain in $DOMAIN_HOME..."
    # 调用 WLST 模板创建 Domain
    $WLST /u01/oracle/setup/oam/create_domain.py
fi

# 启动 Admin Server 以便后续集成配置
echo "Starting Admin Server to perform integration setup..."
$DOMAIN_HOME/bin/startWebLogic.sh &
sleep 60 # 等待启动

# 执行 OAM-OUD 集成配置
echo "Configuring OUD as Identity Store..."
$WLST /u01/oracle/setup/oam/config_oud_integration.py
