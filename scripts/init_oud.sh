#!/bin/bash
# -------------------------------------------------------------------------
# OUD 数据初始化脚本
# -------------------------------------------------------------------------

source .env 2>/dev/null || true

OUD_HOST="iam-oud"
OUD_PORT="1389"
ADMIN_DN="${OUD_ROOT_DN:-cn=Directory Manager}"
ADMIN_PWD="${OUD_PWD:-Welcome1}"

echo "正在检查 OUD 是否在 $OUD_HOST:$OUD_PORT 上运行..."
# 等待 LDAP 响应
until docker exec iam-oud /u01/oracle/oud/bin/ldapsearch -h localhost -p 1389 -D "$ADMIN_DN" -w "$ADMIN_PWD" -b "" -s base "objectclass=*" > /dev/null 2>&1; do
  echo "OUD LDAP 仍未就绪。等待中..."
  sleep 5
done

echo "正在导入 LDIF 文件..."
for f in ldif/*.ldif; do
  echo "正在处理 $f..."
  docker exec -i iam-oud /u01/oracle/oud/bin/ldapmodify -h localhost -p 1389 -D "$ADMIN_DN" -w "$ADMIN_PWD" -a < "$f"
done

echo "OUD 数据导入完成。"
