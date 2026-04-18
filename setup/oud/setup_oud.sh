#!/bin/bash
# -------------------------------------------------------------------------
# OUD 实例初始化脚本
# -------------------------------------------------------------------------

if [ -f /u01/oracle/.env ]; then
    set -a
    source /u01/oracle/.env
    set +a
fi

INSTANCE_HOME="/u01/oracle/user_projects/${OUD_INSTANCE_NAME:-oud_inst1}/OUD"

if [ -d "$INSTANCE_HOME" ]; then
    echo "OUD 实例已存在于 $INSTANCE_HOME。跳过创建。"
else
    echo "正在创建支持 REST API 的 OUD 实例于 $INSTANCE_HOME..."
    /u01/oracle/oud/oud-setup \
      --cli \
      --baseDN dc=example,dc=com \
      --ldapPort ${ldapPort:-1389} \
      --adminConnectorPort ${adminConnectorPort:-4444} \
      --httpAdminConnectorPort ${httpAdminConnectorPort:-8444} \
      --rootUserDN "${rootUserDN:-cn=Directory Manager}" \
      --rootUserPassword "${rootUserPassword:-Welcome1}" \
      --ldapPort ${ldapPort:-1389} \
      --ldapsPort ${ldapsPort:-1636} \
      --httpPort ${httpPort:-1080} \
      --httpsPort ${httpsPort:-1081} \
      --generateSelfSignedCertificate \
      --sampleData 200 \
      --serverTuning jvm-default \
      --offlineToolsTuning jvm-default \
      --no-prompt \
      --noPropertiesFile
fi

# 配置全局 ACI 以允许用户访问自己的条目（REST API 所需）
echo "正在更新全局 ACI 以支持自我读取访问..."
/u01/oracle/user_projects/${OUD_INSTANCE_NAME:-oud_inst1}/OUD/bin/dsconfig set-access-control-handler-prop \
  --hostname localhost \
  --port ${adminConnectorPort:-4444} \
  --trustAll \
  --bindDN "${rootUserDN:-cn=Directory Manager}" \
  --bindPassword "${rootUserPassword:-Welcome1}" \
  --add "global-aci:(targetattr!=\"userPassword||authPassword\")(version 3.0; acl \"Self read access\"; allow (read,search,compare) userdn=\"ldap:///self\";)" \
  --no-prompt
