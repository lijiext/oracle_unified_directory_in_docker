#!/bin/bash
# -------------------------------------------------------------------------
# OHS & WebGate Setup Script (Runs inside OHS container)
# -------------------------------------------------------------------------

if [ -f /u01/oracle/.env ]; then
    set -a
    source /u01/oracle/.env
    set +a
fi

OHS_DOMAIN_HOME="/u01/oracle/user_projects/domains/ohsDomain"
OHS_INST_NAME="${OHS_COMPONENT_NAME:-ohs1}"
WLST="/u01/oracle/oracle_common/common/bin/wlst.sh"

# 检查 OHS 实例是否已启动
echo "Checking if OHS instance $OHS_INST_NAME is running..."
max_retries=10
count=0
while ! curl -s http://localhost:7777 > /dev/null; do
    echo "Waiting for OHS instance to respond... ($count/$max_retries)"
    sleep 30
    count=$((count + 1))
    if [ $count -ge $max_retries ]; then
        echo "OHS instance failed to respond. Please check OHS container logs."
        exit 1
    fi
done
echo "OHS instance is up and running."

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
