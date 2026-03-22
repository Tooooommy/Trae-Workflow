---
name: ios-native-patterns
description: iOS 原生开发、SwiftUI/UIKit、并发模型和架构模式最佳实践。适用于所有 iOS 原生项目。
---

# iOS 原生开发模式

用于构建高性能、可维护 iOS 应用的 Swift 模式与最佳实践。

## 何时激活

- 编写新的 iOS 原生应用
- 设计 iOS 架构模式
- 实现 SwiftUI/UIKit 界面
- 处理 iOS 并发和数据

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Swift | 5.9+ | 5.10+ |
| iOS | 17.0+ | 18.0+ |
| SwiftUI | 5.0+ | 最新 |
| SwiftData | 1.0+ | 最新 |
| Xcode | 15.0+ | 16.0+ |

## 核心原则

### 1. SwiftUI 优先

```swift
import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.users.isEmpty {
                    EmptyStateView()
                } else {
                    userList
                }
            }
            .navigationTitle("Users")
            .task {
                await viewModel.loadUsers()
            }
        }
    }
    
    private var userList: some View {
        List(viewModel.users) { user in
            UserRowView(user: user)
                .onTapGesture {
                    viewModel.selectUser(user)
                }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

### 2. MVVM 架构

```swift
import Foundation

@MainActor
@Observable
class UserViewModel {
    private(set) var users: [User] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    
    private let userService: UserService
    
    init(userService: UserService = .shared) {
        self.userService = userService
    }
    
    func loadUsers() async {
        isLoading = true
        error = nil
        
        do {
            users = try await userService.fetchUsers()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await loadUsers()
    }
    
    func selectUser(_ user: User) {
        // Navigation logic
    }
}
```

### 3. 依赖注入

```swift
protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
    func fetchUser(id: String) async throws -> User
}

class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchUsers() async throws -> [User] {
        return try await apiClient.request(endpoint: .users)
    }
    
    func fetchUser(id: String) async throws -> User {
        return try await apiClient.request(endpoint: .user(id))
    }
}

// 使用 @Environment 注入
struct ContentView: View {
    @Environment(UserService.self) private var userService
    
    var body: some View {
        UserListView()
            .environment(userService)
    }
}

// App 入口
@main
struct MyApp: App {
    @State private var userService = UserService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(userService)
        }
    }
}
```

## 并发模式

### async/await

```swift
class DataRepository {
    private let apiClient: APIClient
    private let cache: Cache<User>
    
    func getUser(id: String) async throws -> User {
        // 检查缓存
        if let cached = cache.get(forKey: id) {
            return cached
        }
        
        // 从 API 获取
        let user = try await apiClient.request(endpoint: .user(id))
        
        // 缓存结果
        cache.set(user, forKey: id)
        
        return user
    }
    
    func loadDashboard() async throws -> Dashboard {
        async let user = getUser(id: "current")
        async let notifications = fetchNotifications()
        async let stats = fetchStats()
        
        return try await Dashboard(
            user: user,
            notifications: notifications,
            stats: stats
        )
    }
}
```

### Actor

```swift
actor DataCache {
    private var cache: [String: Any] = [:]
    private var accessCount: [String: Int] = [:]
    
    func get<T>(key: String) -> T? {
        accessCount[key, default: 0] += 1
        return cache[key] as? T
    }
    
    func set<T>(_ value: T, forKey key: String) {
        cache[key] = value
    }
    
    func remove(forKey key: String) {
        cache.removeValue(forKey: key)
        accessCount.removeValue(forKey: key)
    }
    
    func getAccessCount(forKey key: String) -> Int {
        accessCount[key] ?? 0
    }
    
    func clearLeastUsed(keeping count: Int) {
        let sorted = accessCount.sorted { $0.value < $1.value }
        let toRemove = sorted.dropLast(count)
        for (key, _) in toRemove {
            cache.removeValue(forKey: key)
            accessCount.removeValue(forKey: key)
        }
    }
}
```

### MainActor

```swift
@MainActor
class UIController {
    private var view: UIView?
    
    func updateUI(with data: Data) {
        view?.configure(with: data)
    }
    
    nonisolated func processData(_ data: Data) async -> ProcessedData {
        // 后台处理
        return heavyProcessing(data)
    }
    
    func processAndUpdate(_ data: Data) async {
        let processed = await processData(data)
        updateUI(with: processed)
    }
}
```

## 数据持久化

### SwiftData

```swift
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var createdAt: Date
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = Date()
    }
}

@Model
class Order {
    var id: String
    var user: User?
    var items: [OrderItem]
    var total: Double
    var status: OrderStatus
    
    init(id: String, user: User? = nil) {
        self.id = id
        self.user = user
        self.items = []
        self.total = 0
        self.status = .pending
    }
}

// 配置
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self, Order.self])
    }
}

// 使用
struct UserListView: View {
    @Query(sort: \User.createdAt, order: .reverse) 
    var users: [User]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(users) { user in
            UserRow(user: user)
        }
        .toolbar {
            Button("Add") {
                let user = User(id: UUID().uuidString, name: "New", email: "new@example.com")
                context.insert(user)
            }
        }
    }
}
```

### CoreData

```swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}

// 使用
class UserRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func fetchUsers() async throws -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserEntity.createdAt, ascending: false)]
        
        return try await context.perform {
            try self.context.fetch(request)
        }
    }
    
    func createUser(name: String, email: String) async throws -> UserEntity {
        try await context.perform {
            let user = UserEntity(context: self.context)
            user.id = UUID()
            user.name = name
            user.email = email
            user.createdAt = Date()
            try self.context.save()
            return user
        }
    }
}
```

## 网络请求

### URLSession

```swift
actor APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let baseURL = "https://api.example.com"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum Endpoint {
    case users
    case user(String)
    case createUser(CreateUserRequest)
    
    var path: String {
        switch self {
        case .users: return "/users"
        case .user(let id): return "/users/\(id)"
        case .createUser: return "/users"
        }
    }
    
    var method: String {
        switch self {
        case .users, .user: return "GET"
        case .createUser: return "POST"
        }
    }
    
    var body: Encodable? {
        switch self {
        case .createUser(let request): return request
        default: return nil
        }
    }
}
```

## UIKit 集成

### UIViewControllerRepresentable

```swift
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

// 使用
struct ProfileView: View {
    @State private var avatar: UIImage?
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            if let avatar = avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            Button("Choose Photo") {
                showPicker = true
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $avatar)
        }
    }
}
```

### UIViewRepresentable

```swift
struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "marker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                view?.annotation = annotation
            }
            
            return view
        }
    }
}
```

## 测试

### 单元测试

```swift
import Testing
@testable import MyApp

@Suite("User ViewModel Tests")
struct UserViewModelTests {
    @Test("Load users successfully")
    func loadUsersSuccess() async throws {
        let mockService = MockUserService()
        mockService.usersToReturn = [
            User(id: "1", name: "Alice", email: "alice@example.com"),
            User(id: "2", name: "Bob", email: "bob@example.com"),
        ]
        
        let viewModel = UserViewModel(userService: mockService)
        await viewModel.loadUsers()
        
        #expect(viewModel.users.count == 2)
        #expect(viewModel.users.first?.name == "Alice")
        #expect(!viewModel.isLoading)
    }
    
    @Test("Handle error")
    func loadUsersError() async throws {
        let mockService = MockUserService()
        mockService.errorToThrow = APIError.networkError
        
        let viewModel = UserViewModel(userService: mockService)
        await viewModel.loadUsers()
        
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.error != nil)
    }
}

class MockUserService: UserServiceProtocol {
    var usersToReturn: [User] = []
    var errorToThrow: Error?
    
    func fetchUsers() async throws -> [User] {
        if let error = errorToThrow {
            throw error
        }
        return usersToReturn
    }
    
    func fetchUser(id: String) async throws -> User {
        throw APIError.notFound
    }
}
```

### UI 测试

```swift
import XCTest

final class UserListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testUserListDisplays() throws {
        let userList = app.collectionViews["UserList"]
        XCTAssertTrue(userList.waitForExistence(timeout: 5))
        
        let firstUser = userList.cells.firstMatch
        XCTAssertTrue(firstUser.exists)
    }
    
    func testUserSelection() throws {
        let userList = app.collectionViews["UserList"]
        userList.cells.firstMatch.tap()
        
        let detailView = app.otherElements["UserDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| @Observable | 可观察状态 |
| @StateObject | 视图模型生命周期 |
| @Query | SwiftData 查询 |
| async/await | 异步编程 |
| Actor | 数据隔离 |
| @MainActor | UI 线程 |

**记住**：SwiftUI 和 Swift 并发是 iOS 开发的未来。使用 MVVM 架构，优先选择 SwiftData 进行持久化，充分利用 async/await 和 Actor 进行并发编程。
