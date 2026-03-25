# Rust Hooks 配置

> Rust 项目开发流程钩子配置

## Cargo 钩子

### pre-commit

```bash
#!/bin/bash
cargo fmt --check
cargo clippy -- -D warnings
cargo test
```

### pre-push

```bash
#!/bin/bash
cargo build --release
cargo test --all-features
```

## Git 钩子安装

```bash
# 使用 cargo-husky
cargo install cargo-husky
cargo husky install
```

## 验证清单

- [ ] 代码格式化检查 (`cargo fmt --check`)
- [ ] Clippy 检查 (`cargo clippy`)
- [ ] 测试通过 (`cargo test`)
- [ ] 文档构建 (`cargo doc`)
