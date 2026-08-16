#!/usr/bin/env bash
set -euo pipefail

# 仅在 MongoDB 数据目录首次初始化时由官方 entrypoint 执行。
# 使用容器环境变量，不硬编码任何密码。

echo ">>> [init] Creating database '${MONGO_DATABASE}' and app user '${MONGO_APP_USERNAME}' (readWrite only) ..."

mongosh --host 127.0.0.1 --port 27017 \
  -u "${MONGO_INITDB_ROOT_USERNAME}" \
  -p "${MONGO_INITDB_ROOT_PASSWORD}" \
  --authenticationDatabase admin \
  --quiet <<'EOF'
const appDb = db.getSiblingDB(process.env.MONGO_DATABASE);

appDb.createUser({
  user: process.env.MONGO_APP_USERNAME,
  pwd: process.env.MONGO_APP_PASSWORD,
  roles: [{ role: "readWrite", db: process.env.MONGO_DATABASE }]
});

appDb.health_check.insertOne({
  message: "mongodb initialized successfully",
  createdAt: new Date()
});
EOF

echo ">>> [init] App user created and health_check seeded."