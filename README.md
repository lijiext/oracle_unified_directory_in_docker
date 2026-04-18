# Oracle Unified Directory (OUD) REST API 部署方案

本项目提供了一个基于 Docker Compose 的轻量化 Oracle Unified Directory (OUD) 部署方案，专注于提供原生的 REST API 访问能力。

## 1. 核心组件

- **Oracle Database (19c)**: 作为 OUD 的底层元数据和数据存储。
- **Oracle Unified Directory (OUD) 12.2.1.4**: 提供 LDAP 目录服务及 REST/SCIM 访问接口。
- **OUD Services Manager (OUDSM)**: 用于图形化管理 OUD 的 Web 控制台。

## 2. 快速开始

### 2.1 环境准备
在启动前，请确保已安装 Docker 和 Docker Compose，并根据需要修改 `.env` 文件中的密码和端口配置。

### 2.2 自动化初始化
项目提供了一个 `init.sh` 脚本，它将严格按照依赖顺序完成以下操作：
1. **清理环境**: 强制删除旧容器和数据卷（确保权限一致性）。
2. **启动数据库**: 等待数据库进入健康状态。
3. **启动 OUD**: 自动执行 `oud-setup` 开启 REST API 支持。
4. **启动 OUDSM**: 自动创建 WebLogic 管理域。
5. **深度设置**: 自动配置 Global ACI（允许用户通过 REST 自我管理）并导入 `ldif/` 下的初始数据。

**运行初始化脚本：**
```bash
chmod +x init.sh scripts/*.sh setup/oud/*.sh
./init.sh
```

## 3. 服务访问地址

| 组件 | 协议 | 访问地址 | 说明 |
| :--- | :--- | :--- | :--- |
| **OUDSM 控制台** | HTTP | [http://localhost:7001/console](http://localhost:7001/console) | 默认用户: weblogic |
| **REST 管理 API** | HTTP | [http://localhost:8444/rest/v1/admin](http://localhost:8444/rest/v1/admin) | 用于 OUD 实例管理 |
| **REST 数据 API** | HTTPS | [https://localhost:1081/rest/v1/directory](https://localhost:1081/rest/v1/directory) | 标准 LDAP 数据操作 |
| **SCIM API** | HTTPS | [https://localhost:1081/iam/directory/oud/scim/v1](https://localhost:1081/iam/directory/oud/scim/v1) | 标准 SCIM 2.0 接口 |
| **LDAP 端口** | TCP | localhost:1389 | 标准 LDAP 访问 |
| **LDAPS 端口** | SSL | localhost:1636 | 加密 LDAP 访问 |

## 4. 目录结构说明

- `docker-compose.yml`: 容器编排定义。
- `.env`: 环境变量与敏感配置。
- `init.sh`: 全局引导脚本。
- `ldif/`: 存放初始化导入的 LDAP 数据文件。
- `setup/oud/`: OUD 容器内部的深度配置脚本。
- `scripts/`: 外部辅助管理脚本。

## 5. 维护与调试

查看实时日志：
```bash
docker compose logs -f iam-oud
```

进入 OUD 容器手动执行命令：
```bash
docker exec -it iam-oud /bin/bash
```
