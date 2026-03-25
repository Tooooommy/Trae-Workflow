---
alwaysApply: false
globs:
  - '**/Cargo.toml'
  - '**/tauri.conf.json'
---

# Tauri 测试规范

> Tauri 桌面应用测试规范。

## 测试类型

| 类型 | 工具 |
|------|------|
| Rust 单元测试 | cargo test |
| Rust 集成测试 | cargo test --test |
| 前端测试 | Vitest |
| E2E 测试 | Playwright |

## Rust 测试

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn example() {
        assert_eq!(2 + 2, 4);
    }
}
```

## E2E 测试

```typescript
import { test, expect } from '@playwright/test';

test('app launches', async ({ page }) => {
  await page.goto('http://localhost:1420');
  await expect(page).toHaveTitle('Tauri App');
});
```
