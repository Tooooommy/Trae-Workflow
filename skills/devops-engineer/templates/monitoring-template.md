# 监控配置

## 概述

| 项目 | 内容 |
|------|------|
| 项目名称 | {PROJECT_NAME} |
| 版本 | v1.0 |
| 日期 | {DATE} |
| 负责人 | devops-engineer |

## 1. 监控架构

### 1.1 监控组件

| 组件 | 用途 |
|------|------|
| Prometheus | 指标采集 |
| Grafana | 可视化 |
| AlertManager | 告警管理 |
| Loki | 日志聚合 |

### 1.2 数据流

```
应用 → Prometheus → Grafana
                  → AlertManager → 通知渠道
```

## 2. 指标配置

### 2.1 基础设施指标

| 指标 | 说明 | 采集频率 |
|------|------|----------|
| cpu_usage | CPU使用率 | 15s |
| memory_usage | 内存使用率 | 15s |
| disk_usage | 磁盘使用率 | 60s |
| network_io | 网络IO | 15s |

### 2.2 应用指标

| 指标 | 说明 | 采集频率 |
|------|------|----------|
| http_requests_total | 请求总数 | 实时 |
| http_request_duration | 请求耗时 | 实时 |
| http_errors_total | 错误总数 | 实时 |
| active_connections | 活跃连接 | 15s |

### 2.3 业务指标

| 指标 | 说明 | 采集频率 |
|------|------|----------|
| | | |

## 3. 告警规则

### 3.1 系统告警

| 告警名称 | 表达式 | 阈值 | 级别 | 持续时间 |
|----------|--------|------|------|----------|
| HighCPU | cpu_usage > 80 | 80% | warning | 5m |
| HighMemory | memory_usage > 85 | 85% | warning | 5m |
| DiskFull | disk_usage > 90 | 90% | critical | 1m |

### 3.2 应用告警

| 告警名称 | 表达式 | 阈值 | 级别 | 持续时间 |
|----------|--------|------|------|----------|
| HighErrorRate | error_rate > 1 | 1% | critical | 1m |
| HighLatency | p99_latency > 500 | 500ms | warning | 5m |
| ServiceDown | up == 0 | - | critical | 1m |

### 3.3 业务告警

| 告警名称 | 表达式 | 阈值 | 级别 | 持续时间 |
|----------|--------|------|------|----------|
| | | | | |

## 4. 告警配置

### 4.1 告警路由

| 接收者 | 级别 | 渠道 |
|--------|------|------|
| ops-team | critical | 邮件、短信、Slack |
| dev-team | warning | 邮件、Slack |
| on-call | critical | 电话 |

### 4.2 静默规则

| 规则 | 时间范围 | 原因 |
|------|----------|------|
| | | |

## 5. 仪表板

### 5.1 系统仪表板

| 面板 | 指标 |
|------|------|
| CPU | cpu_usage |
| 内存 | memory_usage |
| 磁盘 | disk_usage |
| 网络 | network_io |

### 5.2 应用仪表板

| 面板 | 指标 |
|------|------|
| 请求量 | http_requests_total |
| 响应时间 | http_request_duration |
| 错误率 | http_errors_total |
| QPS | rate(http_requests_total) |

### 5.3 业务仪表板

| 面板 | 指标 |
|------|------|
| | |

## 6. 日志配置

### 6.1 日志采集

| 日志类型 | 路径 | 格式 |
|----------|------|------|
| 应用日志 | /var/log/app/*.log | JSON |
| 访问日志 | /var/log/nginx/*.log | JSON |
| 错误日志 | /var/log/app/error.log | JSON |

### 6.2 日志保留

| 日志类型 | 保留时间 | 存储位置 |
|----------|----------|----------|
| 应用日志 | 30天 | Loki |
| 访问日志 | 7天 | Loki |
| 错误日志 | 90天 | Loki |

## 7. SLO 配置

### 7.1 服务等级目标

| SLO | 目标 | 计算方式 |
|-----|------|----------|
| 可用性 | 99.9% | uptime / total_time |
| 响应时间 | P99 < 200ms | histogram_quantile |
| 错误率 | < 0.1% | errors / total_requests |

### 7.2 错误预算

| 项目 | 值 |
|------|------|
| 月度预算 | 43.2 分钟 |
| 已消耗 | 分钟 |
| 剩余 | 分钟 |

## 8. 变更日志

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | | 初始版本 |
