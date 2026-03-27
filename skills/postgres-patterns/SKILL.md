---
name: postgres-patterns
description: 用于查询优化、模式设计、索引和安全性的PostgreSQL数据库模式。基于Supabase最佳实践。**必须激活当**：用户要求优化 SQL 查询、设计数据库模式、创建索引或排查数据库性能问题时。即使用户没有明确说"PostgreSQL"，当涉及 SQL 查询优化、数据库设计或性能调优时也应使用。
---

# PostgreSQL 模式

PostgreSQL 最佳实践快速参考。

## 何时激活

- 编写 SQL 查询或迁移时
- 设计数据库模式时
- 排查慢查询时
- 实施行级安全性时
- 设置连接池时

## 技术栈版本

| 技术               | 最低版本 | 推荐版本 |
| ------------------ | -------- | -------- |
| PostgreSQL         | 15+      | 17+      |
| pg_stat_statements | 内置     | 启用     |
| Supabase           | 最新     | 最新     |
| pgvector           | 0.5+     | 最新     |
| pgpool-II          | 4.5+     | 最新     |

## 查询优化

### 索引速查表

| 查询模式                | 索引类型       | 示例                                     |
| ----------------------- | -------------- | ---------------------------------------- |
| `WHERE col = value`     | B-tree（默认） | `CREATE INDEX idx ON t (col)`            |
| `WHERE col > value`     | B-tree         | `CREATE INDEX idx ON t (col)`            |
| `WHERE a = x AND b > y` | 复合索引       | `CREATE INDEX idx ON t (a, b)`           |
| `WHERE jsonb @> '{}'`   | GIN            | `CREATE INDEX idx ON t USING gin (col)`  |
| `WHERE tsv @@ query`    | GIN            | `CREATE INDEX idx ON t USING gin (col)`  |
| 时间序列范围查询        | BRIN           | `CREATE INDEX idx ON t USING brin (col)` |

### 复合索引顺序

```sql
-- 等值列在前，范围列在后
CREATE INDEX idx ON orders (status, created_at);
-- 适用于: WHERE status = 'pending' AND created_at > '2024-01-01'
```

### 覆盖索引

```sql
CREATE INDEX idx ON users (email) INCLUDE (name, created_at);
-- 避免 SELECT email, name, created_at 时的表查找
```

### 部分索引

```sql
CREATE INDEX idx ON users (email) WHERE deleted_at IS NULL;
-- 更小的索引，只包含活跃用户
```

### 函数索引

```sql
-- 经常按 lowercase 查询时
CREATE INDEX idx ON users (lower(email));

-- 时间戳截断
CREATE INDEX idx ON orders (date_trunc('month', created_at));
```

## 模式设计

### 数据类型快速参考

| 使用场景 | 正确类型        | 避免使用         |
| -------- | --------------- | ---------------- |
| ID       | `bigint`        | `int`，随机 UUID |
| 字符串   | `text`          | `varchar(255)`   |
| 时间戳   | `timestamptz`   | `timestamp`      |
| 货币     | `numeric(10,2)` | `float`          |
| 标志位   | `boolean`       | `varchar`，`int` |

### 主键策略

```sql
-- 顺序 UUID（推荐）
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- 或使用序列 ID
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY
);

-- 不要使用随机 UUID 作为主键（索引膨胀）
```

### JSONB 最佳实践

```sql
-- 存储半结构化数据
CREATE TABLE events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  payload jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- GIN 索引加速查询
CREATE INDEX idx_events_payload ON events USING gin (payload);

-- 查询 JSONB 字段
SELECT * FROM events WHERE payload @> '{"type": "click"}';
SELECT payload->>'user_id' FROM events WHERE payload ? 'user_id';
```

## 常见模式

### UPSERT

```sql
INSERT INTO settings (user_id, key, value)
VALUES (123, 'theme', 'dark')
ON CONFLICT (user_id, key)
DO UPDATE SET value = EXCLUDED.value;
```

### 游标分页

```sql
-- 比 OFFSET 更高效
SELECT * FROM products
WHERE id > $last_id
ORDER BY id
LIMIT 20;
-- O(1) vs OFFSET 的 O(n)
```

### 队列处理

```sql
UPDATE jobs SET status = 'processing'
WHERE id = (
  SELECT id FROM jobs
  WHERE status = 'pending'
  ORDER BY created_at
  LIMIT 1
  FOR UPDATE SKIP LOCKED
) RETURNING *;
```

### 行级安全性 (RLS)

```sql
-- 启用 RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 策略（注意：包装在 SELECT 中）
CREATE POLICY policy ON orders
  FOR ALL
  USING ((SELECT auth.uid()) = user_id);

-- 测试 RLS
SET ROLE anon;
SELECT * FROM orders; -- 只返回当前用户的订单
```

## 性能诊断

### 反模式检测

```sql
-- 查找未索引的外键
SELECT conrelid::regclass, a.attname
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey)
  );

-- 查找慢查询
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;

-- 检查表膨胀
SELECT relname, n_dead_tup, last_vacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

### EXPLAIN ANALYZE

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders
WHERE user_id = 123 AND status = 'pending';
```

### 监控视图

```sql
-- 活跃查询
SELECT pid, usename, query, state, query_start
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- 终止长时间查询
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'active' AND query_start < now() - interval '10 minutes';
```

## 配置模板

```sql
-- 连接限制（根据 RAM 调整）
ALTER SYSTEM SET max_connections = 100;
ALTER SYSTEM SET work_mem = '8MB';

-- 超时设置
ALTER SYSTEM SET idle_in_transaction_session_timeout = '30s';
ALTER SYSTEM SET statement_timeout = '30s';

-- 监控扩展
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 安全默认值
REVOKE ALL ON SCHEMA public FROM public;

-- 重新加载配置
SELECT pg_reload_conf();
```

## Supabase 集成

### Auth 函数

```sql
-- 获取当前用户 ID
SELECT auth.uid();

-- 获取当前用户角色
SELECT auth.jwt()->>'role';

-- 保护函数
CREATE FUNCTION get_user_data()
RETURNS TABLE(id uuid, email text)
LANGUAGE sql SECURITY DEFINER
AS $$
  SELECT id, email FROM users
  WHERE id = auth.uid();
$$;
```

### Storage 模式

```sql
-- 公开 bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- 上传文件（通过 API）
-- 访问: https://xxx.supabase.co/storage/v1/object/public/avatars/user123.png
```

## 相关技能

| 技能              | 说明                     |
| ----------------- | ------------------------ |
| backend-expert    | API 和后端模式           |
| database-patterns | 数据库模式和迁移最佳实践 |
| clickhouse-io     | ClickHouse 分析模式      |
| cache-strategy-patterns  | 缓存模式                 |

---

_基于 Supabase 最佳实践（致谢：Supabase 团队）_
