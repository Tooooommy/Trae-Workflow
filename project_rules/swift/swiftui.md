---
alwaysApply: false
globs:
  - "**/*.xcodeproj"
  - "**/ContentView.swift"
---

# SwiftUI 项目规范与指南

> 基于 SwiftUI 的 iOS/macOS 应用开发规范。

## 项目总览

* 技术栈: Swift 5.10+, SwiftUI, Combine, iOS 17+
* 架构: MVVM, 声明式 UI

## 关键规则

### 项目结构

```
App/
├── App/
│   ├── AppApp.swift           # App 入口
│   ├── ContentView.swift      # 主视图
│   ├── Models/
│   │   └── User.swift
│   ├── ViewModels/
│   │   └── UserViewModel.swift
│   ├── Views/
│   │   ├── Components/
│   │   │   └── UserCard.swift
│   │   └── Screens/
│   │       └── UserListView.swift
│   ├── Services/
│   │   └── APIService.swift
│   ├── Repositories/
│   │   └── UserRepository.swift
│   └── Utils/
│       └── Extensions.swift
├── Resources/
│   └── Assets.xcassets
└── Tests/
```

### View

```swift
import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.users) { user in
                UserCard(user: user)
                    .onTapGesture {
                        viewModel.selectUser(user)
                    }
            }
            .navigationTitle("Users")
            .task {
                await viewModel.loadUsers()
            }
            .refreshable {
                await viewModel.loadUsers()
            }
        }
    }
}
```

### ViewModel

```swift
import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let repository: UserRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: UserRepository = UserRepository()) {
        self.repository = repository
    }

    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }

        do {
            users = try await repository.fetchUsers()
        } catch {
            self.error = error
        }
    }

    func selectUser(_ user: User) {
        // Handle selection
    }
}
```

### Model

```swift
import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case createdAt = "created_at"
    }
}
```

## 开发命令

```bash
xcodebuild -scheme App build    # 构建
xcodebuild test                 # 测试
xcodebuild -scheme App archive  # 归档
```
