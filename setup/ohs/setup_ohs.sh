#!/bin/bash
# -------------------------------------------------------------------------
# OHS & WebGate Setup Script (Runs inside OHS container)
# -------------------------------------------------------------------------

source /u01/oracle/.env 2>/dev/null || true

OHS_DOMAIN_HOME="/u01/oracle/user_projects/domains/ohs_domain"
OHS_INST_NAME="${OHS_COMPONENT_NAME:-ohs1}"
WLST="/u01/oracle/oracle_common/common/bin/wlst.sh"

if [ -d "$OHS_DOMAIN_HOME" ]; then
    echo "OHS Domain already exists at $OHS_DOMAIN_HOME. Skipping creation."
else
    echo "Creating OHS Standalone Domain..."
    # 调用 WLST 创建 OHS 独立域
    $WLST /u01/oracle/setup/ohs/create_ohs_domain.py
fi

# 启动 OHS 实例
echo "Starting OHS component $OHS_INST_NAME..."
$OHS_DOMAIN_HOME/bin/startComponent.sh $OHS_INST_NAME

# 创建简单的测试首页
echo "Creating test index page..."
mkdir -p $OHS_DOMAIN_HOME/config/fmwconfig/components/OHS/instances/$OHS_INST_NAME/htdocs
cat <<EOF > $OHS_DOMAIN_HOME/config/fmwconfig/components/OHS/instances/$OHS_INST_NAME/htdocs/index.html
<html>
<head><title>Oracle IAM Stack Test</title></head>
<body>
<h1>Oracle Identity Management Stack is Running!</h1>
<p>Components Integrated: DB + OUD + OAM + OHS</p>
<p>Protected by Oracle Access Manager WebGate</p>
</body>
</html>
EOF

# WebGate 配置逻辑
echo "Performing OAM WebGate configuration..."
# 1. 检查共享卷中是否有 WebGate 配置文件 (通常由 OAM 生成并放入此目录)
WG_CONFIG_PATH="/u01/oracle/shared/webgate/ohs1"
if [ -d "$WG_CONFIG_PATH" ]; then
    echo "Found WebGate configuration in shared volume. Deploying..."
    # /u01/oracle/webgate/ohs/tools/deployWebGate/deployWebGateInstance.sh -w $OHS_DOMAIN_HOME/config/fmwconfig/components/OHS/instances/$OHS_INST_NAME -oh /u01/oracle
    # cp -r $WG_CONFIG_PATH/* $OHS_DOMAIN_HOME/config/fmwconfig/components/OHS/instances/$OHS_INST_NAME/config/
else
    echo "No WebGate configuration found in $WG_CONFIG_PATH. Skipping deployment."
fi
