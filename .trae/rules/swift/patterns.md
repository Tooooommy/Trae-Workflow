---
alwaysApply: false
globs:
  - '**/*.swift'
  - '**/Package.swift'
---

# Swift 模式

> Swift 语言特定的架构模式。

## 面向协议的设计

定义小型、专注的协议。使用协议扩展来提供共享的默认实现：

```swift
protocol Repository: Sendable {
    associatedtype Item: Identifiable & Sendable
    func find(by id: Item.ID) async throws -> Item?
    func save(_ item: Item) async throws
}
```

## 值类型

- 使用结构体（struct）作为数据传输对象和模型
- 使用带有关联值的枚举（enum）来建模不同的状态：

```swift
enum LoadState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)
}
```

## 相关智能体

- `architect` - 架构设计和模式选择

## 相关技能

- `swiftui-patterns` - SwiftUI 架构模式
- `ios-native-patterns` - iOS 原生模式
- `clean-architecture` - 整洁架构
