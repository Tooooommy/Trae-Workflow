---
alwaysApply: false
globs:
  - '**/*.ts'
  - '**/*.tsx'
  - '**/*.js'
  - '**/*.jsx'
---

# TypeScript/JavaScript 编码风格

> TypeScript/JavaScript 语言特定的编码规范。

## 不可变性

使用展开运算符进行不可变更新：

```typescript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name; // MUTATION!
  return user;
}

// CORRECT: Immutability
function updateUser(user, name) {
  return {
    ...user,
    name,
  };
}
```

## 相关智能体

- `code-reviewer` - 代码质量和规范检查

## 相关技能

- `coding-standards` - 通用编码标准
