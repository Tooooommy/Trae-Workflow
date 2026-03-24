---
name: ios-native-patterns
description: iOS 原生开发模式，涵盖 SwiftUI、UIKit、Swift Concurrency、Actor 模式、iOS 26 液态玻璃设计以及现代 iOS/macOS 开发最佳实践。
---

# iOS 原生开发模式

适用于 Apple 平台的现代 iOS 开发模式，涵盖 SwiftUI、UIKit、Swift Concurrency、Actor 模式、iOS 26 特性等。用于构建声明式、高性能的用户界面和后端逻辑。

## 何时激活

- 构建 SwiftUI 视图和管理状态时（`@State`、`@Observable`、`@Binding`）
- 使用 `NavigationStack` 设计导航流程时
- 构建视图模型和数据流时
- 优化列表和复杂布局的渲染性能时
- 在 SwiftUI 中使用环境值和依赖注入时
- 使用 Swift 6.2 并发性时
- 构建 Actor 持久化层时
- 编写可测试的 Swift 代码时
- 使用 iOS 26 新特性时（Liquid Glass、FoundationModels）

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| Swift      | 5.9+     | 6.0+     |
| Xcode      | 15.0+    | 16.0+    |
| iOS        | 17.0+    | 18.0+    |
| macOS      | 14.0+    | 15.0+    |
| SwiftUI    | 5.0+     | 最新     |

---

## SwiftUI 状态管理

### 属性包装器选择

选择最适合的最简单包装器：

| 包装器                       | 使用场景                                       |
| ---------------------------- | ---------------------------------------------- |
| `@State`                     | 视图本地的值类型（开关、表单字段、Sheet 展示） |
| `@Binding`                   | 指向父视图 `@State` 的双向引用                 |
| `@Observable` 类 + `@State`  | 拥有多个属性的自有模型                         |
| `@Observable` 类（无包装器） | 从父视图传递的只读引用                         |
| `@Bindable`                  | 指向 `@Observable` 属性的双向绑定              |
| `@Environment`               | 通过 `.environment()` 注入的共享依赖项         |

### @Observable ViewModel

使用 `@Observable`（而非 `ObservableObject`）—— 它跟踪属性级别的变更，因此 SwiftUI 只会重新渲染读取了已变更属性的视图：

```swift
@Observable
final class ItemListViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    var searchText = ""

    private let repository: any ItemRepository

    init(repository: any ItemRepository = DefaultItemRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        items = (try? await repository.fetchAll()) ?? []
    }
}
```

### 消费 ViewModel 的视图

```swift
struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel = ItemListViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .searchable(text: $viewModel.searchText)
        .overlay { if viewModel.isLoading { ProgressView() } }
        .task { await viewModel.load() }
    }
}
```

### 环境注入

用 `@Environment` 替换 `@EnvironmentObject`：

```swift
// Inject
ContentView()
    .environment(authManager)

// Consume
struct ProfileView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        Text(auth.currentUser?.name ?? "Guest")
    }
}
```

---

## SwiftUI 视图组合

### 提取子视图以限制失效

将视图拆分为小型、专注的结构体。当状态变更时，只有读取该状态的子视图会重新渲染：

```swift
struct OrderView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        VStack {
            OrderHeader(title: viewModel.title)
            OrderItemList(items: viewModel.items)
            OrderTotal(total: viewModel.total)
        }
    }
}
```

### 用于可复用样式的 ViewModifier

```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
```

---

## SwiftUI 导航

### 类型安全的 NavigationStack

使用 `NavigationStack` 与 `NavigationPath` 来实现程序化、类型安全的路由：

```swift
@Observable
final class Router {
    var path = NavigationPath()

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

enum Destination: Hashable {
    case detail(Item.ID)
    case settings
    case profile(User.ID)
}

struct RootView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .detail(let id): ItemDetailView(itemID: id)
                    case .settings: SettingsView()
                    case .profile(let id): ProfileView(userID: id)
                    }
                }
        }
        .environment(router)
    }
}
```

---

## SwiftUI 性能

### 为大型集合使用惰性容器

`LazyVStack` 和 `LazyHStack` 仅在视图可见时才创建它们：

```swift
ScrollView {
    LazyVStack(spacing: 8) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### 稳定的标识符

在 `ForEach` 中始终使用稳定、唯一的 ID —— 避免使用数组索引：

```swift
// Use Identifiable conformance or explicit id
ForEach(items, id: \.stableID) { item in
    ItemRow(item: item)
}
```

### 避免在 body 中进行昂贵操作

- 切勿在 `body` 内执行 I/O、网络调用或繁重计算
- 使用 `.task {}` 处理异步工作 —— 当视图消失时它会自动取消
- 在滚动视图中谨慎使用 `.sensoryFeedback()` 和 `.geometryGroup()`
- 在列表中最小化使用 `.shadow()`、`.blur()` 和 `.mask()` —— 它们会触发屏幕外渲染

### 遵循 Equatable

对于 body 计算昂贵的视图，遵循 `Equatable` 以跳过不必要的重新渲染：

```swift
struct ExpensiveChartView: View, Equatable {
    let dataPoints: [DataPoint] // DataPoint must conform to Equatable

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.dataPoints == rhs.dataPoints
    }

    var body: some View {
        // Complex chart rendering
    }
}
```

---

## SwiftUI 预览

使用 `#Preview` 宏配合内联模拟数据以进行快速迭代：

```swift
#Preview("Empty state") {
    ItemListView(viewModel: ItemListViewModel(repository: EmptyMockRepository()))
}

#Preview("Loaded") {
    ItemListView(viewModel: ItemListViewModel(repository: PopulatedMockRepository()))
}
```

---

## Swift 6.2 并发性

### 核心问题：隐式的后台卸载

在 Swift 6.1 及更早版本中，异步函数可能会被隐式卸载到后台线程，即使在看似安全的代码中也会导致数据竞争错误：

```swift
// Swift 6.1: ERROR
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        guard let data = try await item.loadTransferable(type: Data.self) else { return nil }

        // Error: Sending 'self.photoProcessor' risks causing data races
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

Swift 6.2 修复了这个问题：异步函数默认保持在调用者所在的 actor 上。

```swift
// Swift 6.2: OK — async stays on MainActor, no data race
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        guard let data = try await item.loadTransferable(type: Data.self) else { return nil }
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

### 隔离的一致性

MainActor 类型现在可以安全地符合非隔离协议：

```swift
protocol Exportable {
    func export()
}

// Swift 6.1: ERROR — crosses into main actor-isolated code
// Swift 6.2: OK with isolated conformance
extension StickerModel: @MainActor Exportable {
    func export() {
        photoProcessor.exportAsPNG()
    }
}
```

编译器确保该一致性仅在主 actor 上使用：

```swift
// OK — ImageExporter is also @MainActor
@MainActor
struct ImageExporter {
    var items: [any Exportable]

    mutating func add(_ item: StickerModel) {
        items.append(item)  // Safe: same actor isolation
    }
}

// ERROR — nonisolated context can't use MainActor conformance
nonisolated struct ImageExporter {
    var items: [any Exportable]

    mutating func add(_ item: StickerModel) {
        items.append(item)  // Error: Main actor-isolated conformance cannot be used here
    }
}
```

### 全局和静态变量

使用 MainActor 保护全局/静态状态：

```swift
// Swift 6.1: ERROR — non-Sendable type may have shared mutable state
final class StickerLibrary {
    static let shared: StickerLibrary = .init()  // Error
}

// Fix: Annotate with @MainActor
@MainActor
final class StickerLibrary {
    static let shared: StickerLibrary = .init()  // OK
}
```

### MainActor 默认推断模式

Swift 6.2 引入了一种模式，默认推断 MainActor — 无需手动标注：

```swift
// With MainActor default inference enabled:
final class StickerLibrary {
    static let shared: StickerLibrary = .init()  // Implicitly @MainActor
}

final class StickerModel {
    let photoProcessor: PhotoProcessor
    var selection: [PhotosPickerItem]  // Implicitly @MainActor
}

extension StickerModel: Exportable {  // Implicitly @MainActor conformance
    func export() {
        photoProcessor.exportAsPNG()
    }
}
```

### 使用 @concurrent 进行后台工作

当需要真正的并行性时，使用 `@concurrent` 显式卸载：

```swift
nonisolated final class PhotoProcessor {
    private var cachedStickers: [String: Sticker] = [:]

    func extractSticker(data: Data, with id: String) async -> Sticker {
        if let sticker = cachedStickers[id] {
            return sticker
        }

        let sticker = await Self.extractSubject(from: data)
        cachedStickers[id] = sticker
        return sticker
    }

    // Offload expensive work to concurrent thread pool
    @concurrent
    static func extractSubject(from data: Data) async -> Sticker { /* ... */ }
}
```

---

## Actor 持久化

### 基于 Actor 的存储库

Actor 模型保证了序列化访问 —— 没有数据竞争，由编译器强制执行。

```swift
public actor LocalRepository<T: Codable & Identifiable> where T.ID == String {
    private var cache: [String: T] = [:]
    private let fileURL: URL

    public init(directory: URL = .documentsDirectory, filename: String = "data.json") {
        self.fileURL = directory.appendingPathComponent(filename)
        // Synchronous load during init (actor isolation not yet active)
        self.cache = Self.loadSynchronously(from: fileURL)
    }

    // MARK: - Public API

    public func save(_ item: T) throws {
        cache[item.id] = item
        try persistToFile()
    }

    public func delete(_ id: String) throws {
        cache[id] = nil
        try persistToFile()
    }

    public func find(by id: String) -> T? {
        cache[id]
    }

    public func loadAll() -> [T] {
        Array(cache.values)
    }

    // MARK: - Private

    private func persistToFile() throws {
        let data = try JSONEncoder().encode(Array(cache.values))
        try data.write(to: fileURL, options: .atomic)
    }

    private static func loadSynchronously(from url: URL) -> [String: T] {
        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

### 用法

由于 actor 隔离，所有调用都会自动变为异步：

```swift
let repository = LocalRepository<Question>()

// Read — fast O(1) lookup from in-memory cache
let question = await repository.find(by: "q-001")
let allQuestions = await repository.loadAll()

// Write — updates cache and persists to file atomically
try await repository.save(newQuestion)
try await repository.delete("q-001")
```

### 与 @Observable ViewModel 结合使用

```swift
@Observable
final class QuestionListViewModel {
    private(set) var questions: [Question] = []
    private let repository: LocalRepository<Question>

    init(repository: LocalRepository<Question> = LocalRepository()) {
        self.repository = repository
    }

    func load() async {
        questions = await repository.loadAll()
    }

    func add(_ question: Question) async throws {
        try await repository.save(question)
        questions = await repository.loadAll()
    }
}
```

---

## 协议依赖注入测试

### 定义小型、专注的协议

每个协议仅处理一个外部关注点。

```swift
// File system access
public protocol FileSystemProviding: Sendable {
    func containerURL(for purpose: Purpose) -> URL?
}

// File read/write operations
public protocol FileAccessorProviding: Sendable {
    func read(from url: URL) throws -> Data
    func write(_ data: Data, to url: URL) throws
    func fileExists(at url: URL) -> Bool
}

// Bookmark storage (e.g., for sandboxed apps)
public protocol BookmarkStorageProviding: Sendable {
    func saveBookmark(_ data: Data, for key: String) throws
    func loadBookmark(for key: String) throws -> Data?
}
```

### 创建默认（生产）实现

```swift
public struct DefaultFileSystemProvider: FileSystemProviding {
    public init() {}

    public func containerURL(for purpose: Purpose) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)
    }
}

public struct DefaultFileAccessor: FileAccessorProviding {
    public init() {}

    public func read(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }

    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }

    public func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}
```

### 创建用于测试的模拟实现

```swift
public final class MockFileAccessor: FileAccessorProviding, @unchecked Sendable {
    public var files: [URL: Data] = [:]
    public var readError: Error?
    public var writeError: Error?

    public init() {}

    public func read(from url: URL) throws -> Data {
        if let error = readError { throw error }
        guard let data = files[url] else {
            throw CocoaError(.fileReadNoSuchFile)
        }
        return data
    }

    public func write(_ data: Data, to url: URL) throws {
        if let error = writeError { throw error }
        files[url] = data
    }

    public func fileExists(at url: URL) -> Bool {
        files[url] != nil
    }
}
```

### 使用默认参数注入依赖项

生产代码使用默认值；测试注入模拟对象。

```swift
public actor SyncManager {
    private let fileSystem: FileSystemProviding
    private let fileAccessor: FileAccessorProviding

    public init(
        fileSystem: FileSystemProviding = DefaultFileSystemProvider(),
        fileAccessor: FileAccessorProviding = DefaultFileAccessor()
    ) {
        self.fileSystem = fileSystem
        self.fileAccessor = fileAccessor
    }

    public func sync() async throws {
        guard let containerURL = fileSystem.containerURL(for: .sync) else {
            throw SyncError.containerNotAvailable
        }
        let data = try fileAccessor.read(
            from: containerURL.appendingPathComponent("data.json")
        )
        // Process data...
    }
}
```

---

## iOS 26 Liquid Glass 设计

### 基本玻璃效果

为任何视图添加 Liquid Glass 的最简单方法：

```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()  // Default: regular variant, capsule shape
```

### 自定义形状和色调

```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect(.regular.tint(.orange).interactive(), in: .rect(cornerRadius: 16.0))
```

关键自定义选项：

- `.regular` — 标准玻璃效果
- `.tint(Color)` — 添加颜色色调以增强突出度
- `.interactive()` — 对触摸和指针交互做出反应
- 形状：`.capsule`（默认）、`.rect(cornerRadius:)`、`.circle`

### 玻璃按钮样式

```swift
Button("Click Me") { /* action */ }
    .glassEffect(.regular.tint(.blue).interactive(), in: .capsule)
```

---

## iOS 26 FoundationModels（设备端 LLM）

### 可用性检查

在创建会话之前，始终检查模型可用性：

```swift
struct GenerativeView: View {
    private var model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            ContentView()
        case .unavailable(.deviceNotEligible):
            Text("Device not eligible for Apple Intelligence")
        case .unavailable(.appleIntelligenceNotEnabled):
            Text("Please enable Apple Intelligence in Settings")
        case .unavailable(.modelNotReady):
            Text("Model is downloading or not ready")
        case .unavailable(let other):
            Text("Model unavailable: \(other)")
        }
    }
}
```

### 基础会话

```swift
// Single-turn: create a new session each time
let session = LanguageModelSession()
let response = try await session.respond(to: "What's a good month to visit Paris?")
print(response.content)
```

### 结构化输出

```swift
struct WeatherQuery: Generable {
    var location: String
    var date: Date
}

let session = LanguageModelSession()
let query: WeatherQuery = try await session.respond(to: "What's the weather in Paris today?")
print(query.location)  // "Paris"
print(query.date)     // Today's date
```

---

## 应避免的反模式

### SwiftUI

- 在新代码中使用 `ObservableObject` / `@Published` / `@StateObject` / `@EnvironmentObject` —— 迁移到 `@Observable`
- 将异步工作直接放在 `body` 或 `init` 中 —— 使用 `.task {}` 或显式的加载方法
- 在不拥有数据的子视图中将视图模型创建为 `@State` —— 改为从父视图传递
- 使用 `AnyView` 类型擦除 —— 对于条件视图，优先选择 `@ViewBuilder` 或 `Group`
- 在向 Actor 传递数据或从 Actor 接收数据时忽略 `Sendable` 要求

### Swift 6.2 并发性

- 对每个异步函数都应用 `@concurrent`（大多数不需要后台执行）
- 在不理解隔离的情况下使用 `nonisolated` 来抑制编译器错误
- 当 actor 提供相同安全性时，仍保留遗留的 `DispatchQueue` 模式
- 在并发相关的 Foundation Models 代码中跳过 `model.availability` 检查
- 与编译器对抗 — 如果它报告数据竞争，代码就存在真正的并发问题
- 假设所有异步代码都在后台运行（Swift 6.2 默认：保持在调用者所在的 actor 上）

### Actor 持久化

- 在 Swift 并发新代码中使用 `DispatchQueue` 或 `NSLock` 而非 actor
- 将内部缓存字典暴露给外部调用者
- 在不进行验证的情况下使文件 URL 可配置
- 忘记所有 actor 方法调用都是 `await` —— 调用者必须处理异步上下文
- 使用 `nonisolated` 来绕过 actor 隔离（违背了初衷）

### 协议依赖注入

- 创建覆盖所有外部访问的单个大型协议
- 模拟没有外部依赖的内部类型
- 使用 `#if DEBUG` 条件语句代替适当的依赖注入
- 与 actor 一起使用时忘记 `Sendable` 一致性
- 过度设计：如果一个类型没有外部依赖，则不需要协议
