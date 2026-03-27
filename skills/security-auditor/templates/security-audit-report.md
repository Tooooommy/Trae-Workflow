# 安全审计报告

> 项目: {项目名称}
> 审计日期: {YYYY-MM-DD}
> 审计人: {security-auditor}
> 版本: {v1.0}

---

## 一、审计概述

### 审计范围

| 范围 | 说明 |
|------|------|
| 代码审计 | 源代码安全检查 |
| 依赖审计 | 第三方依赖漏洞扫描 |
| 配置审计 | 服务器配置检查 |
| API审计 | 接口安全检查 |

### 审计标准

- OWASP Top 10
- CWE/SANS Top 25
- 行业安全规范

---

## 二、漏洞汇总

### 漏洞统计

| 严重程度 | 数量 | 状态 |
|----------|------|------|
| 严重 (Critical) | X | 待修复 |
| 高危 (High) | X | 待修复 |
| 中危 (Medium) | X | 待修复 |
| 低危 (Low) | X | 待修复 |
| 信息 (Info) | X | 已知悉 |

### 漏洞列表

| ID | 漏洞名称 | 严重程度 | 位置 | 状态 |
|----|----------|----------|------|------|
| VUL-001 | SQL注入 | Critical | /api/users | 待修复 |
| VUL-002 | XSS | High | /components/Form | 待修复 |

---

## 三、漏洞详情

### VUL-001: SQL注入漏洞

#### 基本信息

| 项目 | 内容 |
|------|------|
| 漏洞类型 | SQL Injection |
| 严重程度 | Critical |
| CVSS评分 | 9.8 |
| 影响范围 | 用户数据泄露 |

#### 漏洞描述

[详细描述漏洞原理和影响]

#### 漏洞位置

```
文件: src/api/users.ts
行号: 45-50
代码: const query = `SELECT * FROM users WHERE id = '${id}'`;
```

#### 复现步骤

1. 发送恶意请求: `GET /api/users?id=' OR '1'='1`
2. 观察返回结果

#### 修复建议

```typescript
// 修复前
const query = `SELECT * FROM users WHERE id = '${id}'`;

// 修复后
const { data } = await supabase.from('users').select('*').eq('id', id);
```

---

## 四、依赖漏洞

### 漏洞依赖列表

| 依赖包 | 版本 | 漏洞 | 严重程度 | 建议版本 |
|--------|------|------|----------|----------|
| lodash | 4.17.15 | CVE-2020-8203 | High | 4.17.21 |
| axios | 0.19.0 | CVE-2020-28168 | Medium | 0.21.1 |

### 修复命令

```bash
npm audit fix
npm update lodash axios
```

---

## 五、配置安全

### 安全配置检查

| 检查项 | 状态 | 说明 |
|--------|------|------|
| HTTPS | ✅ 通过 | 已启用HTTPS |
| CSP | ❌ 失败 | 未配置CSP |
| CORS | ⚠️ 警告 | 配置过于宽松 |
| HSTS | ✅ 通过 | 已启用HSTS |

### 建议配置

```typescript
// 安全头配置
const securityHeaders = {
  'Content-Security-Policy': "default-src 'self'",
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
};
```

---

## 六、API安全

### 接口安全检查

| 接口 | 认证 | 授权 | 限流 | 输入验证 |
|------|------|------|------|----------|
| /api/users | ✅ | ✅ | ✅ | ✅ |
| /api/login | ❌ | N/A | ⚠️ | ✅ |

### 敏感接口清单

| 接口 | 敏感操作 | 保护措施 |
|------|----------|----------|
| /api/users/password | 修改密码 | 二次验证 |
| /api/admin/* | 管理操作 | 角色验证 |

---

## 七、修复优先级

### 立即修复 (Critical)

1. VUL-001: SQL注入漏洞
2. 更新 lodash 到安全版本

### 本周修复 (High)

1. VUL-002: XSS漏洞
2. 配置CSP策略

### 下版本修复 (Medium)

1. 收紧CORS配置
2. 添加登录限流

---

## 八、最佳实践建议

### 代码层面

- [ ] 所有用户输入进行验证和转义
- [ ] 使用参数化查询
- [ ] 敏感数据加密存储
- [ ] 错误信息不暴露敏感信息

### 配置层面

- [ ] 启用安全头
- [ ] 配置HTTPS
- [ ] 设置合理的CORS策略
- [ ] 启用访问日志

### 流程层面

- [ ] 定期安全审计
- [ ] 依赖漏洞扫描
- [ ] 代码审查流程
- [ ] 安全培训

---

## 附录

### 审计工具

| 工具 | 用途 |
|------|------|
| npm audit | 依赖漏洞扫描 |
| SonarQube | 代码安全扫描 |
| OWASP ZAP | 渗透测试 |

### 参考文档

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)

### 变更记录

| 日期 | 变更内容 | 作者 |
|------|----------|------|
| YYYY-MM-DD | 初始版本 | @security-auditor |
