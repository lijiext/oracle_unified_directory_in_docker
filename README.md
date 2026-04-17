# Oracle 企业级身份服务集成方案 (IAM Stack)

本方案提供了一个基于 Docker Compose 的集成环境，包含了 Oracle 身份管理核心组件：
- **Oracle Database (19c)**: 用于存储 OAM 的 RCU 元数据。
- **Oracle Unified Directory (OUD)**: 提供 LDAP 用户目录服务。
- **OUD Services Manager (OUDSM)**: 用于图形化管理 OUD。
- **Oracle Access Manager (OAM)**: 提供单点登录 (SSO) 和身份认证。
- **Oracle HTTP Server (OHS)**: 作为反向代理并集成 OAM WebGate。

## 1. 快速开始

### 1.1 环境变量配置
在启动前，请根据需要修改 `.env` 文件中的密码和端口配置。

### 1.2 自动化初始化流程
项目提供了一个 `init.sh` 脚本，它将自动按顺序完成以下操作：
1. 启动 `iam-db`, `iam-oud`, `iam-oudsm`。
2. 等待数据库健康检查通过。
3. 自动导入 `ldif/*.ldif` 中的 LDAP 数据到 OUD。
4. 启动 `iam-oam` 容器并自动执行 RCU 创建必要的 Schema。
5. 启动所有剩余服务（包括 `iam-ohs`）。

**运行初始化脚本：**
```bash
chmod +x init.sh scripts/*.sh
./init.sh
```

## 2. 访问地址

| 组件 | URL | 默认凭据 |
| :--- | :--- | :--- |
| **OUDSM** | http://localhost:7001/oudsm | 见 .env (OUD_PWD) |
| **OAM Console** | http://localhost:7002/oamconsole | 见 .env (OAM_ADMIN_PWD) |
| **OHS (HTTP)** | http://localhost:7777 | - |
| **OHS (HTTPS)** | https://localhost:4443 | - |

## 3. 架构集成细节说明

### 3.1 深度 Setup 逻辑 (Deep Setup)
与普通的容器启动不同，本项目在 `init.sh` 中集成了深层配置逻辑：
- **OUD Setup**: 自动调用 `dssetup` 创建目录实例。
- **OAM Setup**: 自动调用 `wlst.sh` 创建 WebLogic 域，并将 OUD 配置为身份存储。
- **OHS Setup**: 自动创建 OHS 独立域，并为 WebGate 部署做好准备。

### 3.2 共享卷 (Shared Data)
项目使用了 Docker 命名卷 `shared_data`，用于在 OAM 和 OHS 容器之间共享 WebGate 配置文件：
- **OAM**: 在集成阶段将 WebGate 代理生成的 `Wallet` 和 `Config` 放入 `/u01/oracle/shared/webgate`。
- **OHS**: 在启动阶段自动从该位置读取配置并部署。

### 3.3 访问地址详情
| 组件 | URL | 描述 |
| :--- | :--- | :--- |
| **测试首页** | http://localhost:7777 | OHS 托管的测试页面 |
| **OUDSM** | http://localhost:7001/oudsm | OUD 管理界面 |
| **OAM Console** | http://localhost:7002/oamconsole | OAM 管理界面 |

## 4. 维护与日志
查看指定服务的日志：
```bash
docker-compose logs -f iam-oam
```
