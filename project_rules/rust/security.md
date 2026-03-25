# Rust 安全规范

> Rust 项目安全最佳实践

## 内存安全

Rust 的所有权系统天然防止：

- 空指针解引用
- 缓冲区溢出
- 双重释放
- 数据竞争

## 依赖安全

```bash
# 审计依赖
cargo audit

# 检查依赖漏洞
cargo outdated
cargo deny check advisories
```

## 敏感数据

- 绝不硬编码密钥
- 使用环境变量或密钥管理器
- 生产环境使用 `.env` 文件

## 错误处理

- 不泄露敏感信息在错误消息中
- 正确处理所有错误
- 使用 `thiserror` 提供安全的错误类型
