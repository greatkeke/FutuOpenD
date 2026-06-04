# FutuOpenD Docker

Futu OpenD API 服务的 Docker 镜像，支持远程行情查询和交易。

## 特性

- **自动下载最新版 OpenD** — 构建时从官方下载，无需手动管理二进制文件
- **跨网交易加密** — 自动生成 RSA 密钥，解决远程交易连接安全限制
- **灵活配置** — 支持配置文件挂载或环境变量注入
- **健康检查** — 内置容器健康状态监控

## 快速开始

### 1. 准备配置文件

```bash
cp config/FutuOpenD.xml.example config/FutuOpenD.xml
# 编辑 config/FutuOpenD.xml，填入你的账号密码
```

### 2. 启动服务

```bash
docker compose up -d
```

### 3. 验证连接

```python
from futu import *
quote_ctx = OpenQuoteContext(host='YOUR_HOST_IP', port=11111)
ret, data = quote_ctx.get_market_snapshot(['HK.00700'])
print(data)
quote_ctx.close()
```

## 配置方式

### 方式一：配置文件（推荐）

```bash
docker run -d \
  -p 11111:11111 \
  -p 22222:22222 \
  -v ./config:/app/config \
  --name futu-opend \
  futu-opend:latest
```

### 方式二：环境变量

```bash
docker run -d \
  -p 11111:11111 \
  -e FUTU_LOGIN_ACCOUNT=100000 \
  -e FUTU_LOGIN_PWD=your_password \
  --name futu-opend \
  futu-opend:latest
```

## 端口说明

| 端口 | 用途 |
|------|------|
| 11111 | API 协议（行情 + 交易） |
| 22222 | Telnet 远程操作命令 |

## 交易加密说明

当 OpenD 监听地址为 `0.0.0.0`（允许远程连接）时，**交易接口要求 RSA 加密**。行情接口不受此限制。

本镜像在启动时自动生成 RSA 私钥，并将其保存在容器的 `/app/config/rsa_private_key.pem`。如果同一个容器通过 `docker restart` 重启，密钥文件会继续保留，不会重新生成。

如果你希望容器被删除后再次创建时仍然保留同一把密钥，请挂载本地 `./config` 目录到容器，这样密钥会写入到宿主机的 `./config/rsa_private_key.pem`，客户端可以直接复用同一文件。

如果你的 Python SDK 连接远程 OpenD 交易时遇到以下错误：
```
cross-network communication, trade connect need to be encrypted
```
说明需要配置 RSA 加密。本镜像已自动处理。

## GitHub Actions 自动构建

推送代码到 `main` 分支会自动：
1. 检测 OpenD 最新版本
2. 构建 Docker 镜像
3. 推送到 Docker Hub

手动触发构建：
```bash
# 通过 GitHub Actions workflow_dispatch 指定版本
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `FUTU_LOGIN_ACCOUNT` | 登录账号 | — |
| `FUTU_LOGIN_PWD` | 登录密码 | — |
| `TZ` | 时区 | `Asia/Shanghai` |

## License

MIT
