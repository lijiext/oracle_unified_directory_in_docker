#!/bin/bash
# -------------------------------------------------------------------------
# IAM Stack 全局初始化脚本
# 编排并设置支持 REST API 的 OUD 环境
# -------------------------------------------------------------------------

source .env

# 0. 清理现有环境
echo "步骤 0: 正在清理现有环境（包括数据卷）..."
docker compose down -v --remove-orphans

# 1. 启动数据库
echo "步骤 1: 正在启动 Oracle 数据库 (iam-db)..."
docker compose up -d iam-db

# 2. 等待数据库就绪
echo "步骤 2: 正在等待数据库 (iam-db) 进入健康状态..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-db)" == "healthy" ]; do
  echo "数据库仍未就绪 (当前状态: $(docker inspect -f '{{.State.Health.Status}}' iam-db))。等待中..."
  sleep 10
done

# 3. 启动 OUD
echo "步骤 3: 正在启动 OUD (iam-oud)..."
docker compose up -d iam-oud

# 4. 等待 OUD 就绪
echo "步骤 4: 正在等待 OUD (iam-oud) 进入健康状态..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-oud)" == "healthy" ]; do
  echo "OUD 仍未就绪 (当前状态: $(docker inspect -f '{{.State.Health.Status}}' iam-oud))。等待中..."
  sleep 10
done

# 5. 启动 OUDSM
echo "步骤 5: 正在启动 OUDSM (iam-oudsm)..."
docker compose up -d iam-oudsm

# 6. 等待 OUDSM 就绪
echo "步骤 6: 正在等待 OUDSM (iam-oudsm) 进入健康状态..."
until [ "$(docker inspect -f '{{.State.Health.Status}}' iam-oudsm)" == "healthy" ]; do
  echo "OUDSM 仍未就绪 (当前状态: $(docker inspect -f '{{.State.Health.Status}}' iam-oudsm))。等待中..."
  sleep 10
done

# 7. 执行 OUD 深度设置
echo "步骤 7: 正在执行 OUD 深度设置 (REST API & ACI)..."
docker exec -it iam-oud /bin/bash /u01/oracle/setup/oud/setup_oud.sh
./scripts/init_oud.sh

# 8. 最终启动所有组件
echo "步骤 8: 正在启动所有组件..."
docker compose up -d

echo "-----------------------------------------------------------"
echo "OUD REST API 栈正在初始化。"
echo "REST 管理 API: http://localhost:8444/rest/v1/admin"
echo "REST 数据 API: https://localhost:1081/rest/v1/directory"
echo "SCIM API: https://localhost:1081/iam/directory/oud/scim/v1"
echo "-----------------------------------------------------------"
