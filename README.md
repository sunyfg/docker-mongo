# Docker Compose MongoDB 本地开发环境

macOS 本地 MongoDB 开发环境。

## 环境要求

- macOS
- Docker Desktop
- Docker Compose V2
- 本机已有镜像 `mongo:latest`（MongoDB 使用本机已有镜像）

## 启动

```bash
docker compose up -d
```

## 查看状态

```bash
docker compose ps
```

## 查看 MongoDB 日志

```bash
docker compose logs -f mongo
```

## MongoDB 本机连接信息

| 配置项 | 值 |
|---|---|
| host | `127.0.0.1` |
| port | 查看 `.env` 中 `MONGO_PORT`（默认 `27017`） |
| database | 查看 `.env` 中 `MONGO_DATABASE`（默认 `app`） |
| username | 查看 `.env` 中 `MONGO_APP_USERNAME`（默认 `app`） |
| password | 查看本地 `.env`（不会写入 README / Git） |
| authSource | 应用用户所在数据库（`MONGO_DATABASE`） |

> 真实密码只在本地 `.env` 中，请勿提交 Git。

## MongoDB URI

连接格式：

```
mongodb://<username>:<password>@127.0.0.1:<port>/<database>?authSource=<database>
```

结构示例（非真实密码）：

```
mongodb://app:<PASSWORD>@127.0.0.1:27017/app?authSource=app
```

## mongosh 连接

进入 Mongo 容器：

```bash
docker compose exec mongo mongosh
```

推荐使用应用用户连接（从 `.env` 读取变量）：

```bash
docker compose exec mongo \
  mongosh "mongodb://${MONGO_APP_USERNAME}:${MONGO_APP_PASSWORD}@127.0.0.1:27017/${MONGO_DATABASE}?authSource=${MONGO_DATABASE}"
```

## 停止

```bash
docker compose down
```

正常停止不会删除 MongoDB 数据。

## 完全删除数据库

> 警告：下面命令会永久删除当前项目本地 MongoDB 数据：

```bash
docker compose down -v
```

只有需要完全重新初始化数据库时才应该执行。之后：

```bash
docker compose up -d
```

这会再次执行 `/docker-entrypoint-initdb.d` 中的初始化脚本。

## 关于初始化脚本的重要说明

`mongo/init/001_init.sh` 不是每次启动容器都会运行，它只在 MongoDB 数据目录**首次初始化**时执行。

因此修改 `mongo/init/001_init.sh` 后直接：

```bash
docker compose restart
```

**不会**重新执行初始化。只有删除当前 MongoDB volume（`docker compose down -v`）并重新启动才会执行。