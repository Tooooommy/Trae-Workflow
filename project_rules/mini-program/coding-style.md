# 小程序代码规范

## 命名规范

| 类型 | 规则 | 示例 |
|------|------|------|
| 页面 | kebab-case | user-info |
| 组件 | PascalCase | UserCard |
| 方法 | camelCase | getUserInfo |
| 常量 | UPPER_SNAKE | MAX_COUNT |

## 文件规范

- 页面 4 件套：.ts/.js, .wxml, .wxss, .json
- 组件 3 件套：.ts/.js, .wxml, .json

## 代码规范

- 使用 TypeScript 优先
- 组件禁用 Component 构造器
- 页面使用 Page 构造器
- 数据放 data 中，方法放 methods 中
