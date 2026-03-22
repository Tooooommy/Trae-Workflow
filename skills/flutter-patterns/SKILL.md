---
name: flutter-patterns
description: Flutter Widget 组合、状态管理、平台集成和性能优化最佳实践。适用于所有 Flutter 项目。
---

# Flutter 开发模式

用于构建高性能、跨平台 Flutter 应用的模式与最佳实践。

## 何时激活

- 编写新的 Flutter Widget
- 设计 Flutter 应用架构
- 实现状态管理
- 优化 Flutter 应用性能

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Flutter | 3.19+ | 3.24+ |
| Dart | 3.3+ | 3.5+ |
| Provider | 6.0+ | 最新 |
| Riverpod | 2.4+ | 最新 |
| go_router | 13.0+ | 最新 |

## 核心原则

### 1. Widget 组合优先

```dart
// GOOD: 组合小 Widget
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              UserAvatar(user: user),
              const SizedBox(width: 12),
              Expanded(child: UserInfo(user: user)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// 提取可复用 Widget
class UserAvatar extends StatelessWidget {
  final User user;
  final double size;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: user.avatarUrl != null
          ? NetworkImage(user.avatarUrl!)
          : null,
      child: user.avatarUrl == null
          ? Text(user.name[0].toUpperCase())
          : null,
    );
  }
}
```

### 2. 不可变 Widget

```dart
// StatelessWidget 用于无状态 UI
class PriceTag extends StatelessWidget {
  final double price;
  final String currency;

  const PriceTag({
    super.key,
    required this.price,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${currency}${price.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
```

### 3. const 构造器

```dart
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.description),
      trailing: PriceTag(price: product.price),
    );
  }
}

// 使用 const 优化重建
ListView(
  children: products.map((p) => ProductItem(product: p)).toList(),
)
```

## 状态管理

### Provider 模式

```dart
// Model
class Counter extends ChangeNotifier {
  int _value = 0;
  int get value => _value;

  void increment() {
    _value++;
    notifyListeners();
  }

  void decrement() {
    _value--;
    notifyListeners();
  }
}

// Provider 设置
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Counter(),
      child: const MyApp(),
    ),
  );
}

// 使用
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 监听变化
        Consumer<Counter>(
          builder: (context, counter, child) {
            return Text('Count: ${counter.value}');
          },
        ),
        // 不监听，直接访问
        ElevatedButton(
          onPressed: context.read<Counter>().increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Riverpod 模式

```dart
// Provider 定义
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

// 使用
class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}

// 异步数据
final userProvider = FutureProvider.family<User, String>((ref, id) async {
  final api = ref.watch(apiProvider);
  return api.getUser(id);
});

// 使用
class UserWidget extends ConsumerWidget {
  final String userId;

  const UserWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### BLoC 模式

```dart
// Events
abstract class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}

// State
class CounterState {
  final int value;
  const CounterState(this.value);
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState(0)) {
    on<Increment>((event, emit) => emit(CounterState(state.value + 1)));
    on<Decrement>((event, emit) => emit(CounterState(state.value - 1)));
  }
}

// Provider
void main() {
  runApp(
    BlocProvider(
      create: (_) => CounterBloc(),
      child: const MyApp(),
    ),
  );
}

// 使用
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return Text('Count: ${state.value}');
          },
        ),
        ElevatedButton(
          onPressed: () => context.read<CounterBloc>().add(Increment()),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

## 导航模式

### 命名路由

```dart
// 路由定义
MaterialApp(
  routes: {
    '/': (context) => const HomePage(),
    '/users': (context) => const UserListPage(),
    '/users/:id': (context) => const UserDetailPage(),
  },
  onGenerateRoute: (settings) {
    if (settings.name?.startsWith('/users/') ?? false) {
      final id = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (context) => UserDetailPage(userId: id),
        settings: settings,
      );
    }
    return null;
  },
);

// 导航
Navigator.pushNamed(context, '/users/123');
Navigator.pushNamed(context, '/users', arguments: {'filter': 'active'});
```

### GoRouter

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserListPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return UserDetailPage(userId: id);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);

MaterialApp.router(routerConfig: router);

// 导航
context.go('/users/123');
context.push('/users/123');
```

### 传递数据

```dart
// 发送页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserDetailPage(user: user),
  ),
);

// 或使用结果
final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(
    builder: (context) => ConfirmDialog(message: 'Delete?'),
  ),
);

if (result == true) {
  // 用户确认
}

// 接收页面
Navigator.pop(context, true);
```

## 异步模式

### FutureBuilder

```dart
class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  Future<User> fetchUser() async {
    final response = await http.get(Uri.parse('/api/users/$userId'));
    return User.fromJson(jsonDecode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final user = snapshot.data!;
        return Column(
          children: [
            Text(user.name),
            Text(user.email),
          ],
        );
      },
    );
  }
}
```

### StreamBuilder

```dart
class MessageList extends StatelessWidget {
  final String chatId;

  const MessageList({super.key, required this.chatId});

  Stream<List<Message>> messageStream() {
    return FirebaseFirestore.instance
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: messageStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return MessageTile(message: messages[index]);
          },
        );
      },
    );
  }
}
```

## 表单处理

### 表单验证

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      // 提交表单
      await auth.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: validatePassword,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: submit,
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

## 性能优化

### ListView 优化

```dart
// 使用 ListView.builder 而非 ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemTile(item: items[index]);
  },
)

// 使用 const 构造器
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return const ItemTile(); // const 优化
  },
)

// 使用 addAutomaticKeepAlives
ListView.builder(
  addAutomaticKeepAlives: true,
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemTile(item: items[index]);
  },
)
```

### 图片优化

```dart
// 使用 cached_network_image
CachedNetworkImage(
  imageUrl: user.avatarUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  cacheKey: user.id,
  memCacheWidth: 200, // 限制内存缓存大小
)

// 本地图片预缓存
precacheImage(AssetImage('assets/image.png'), context);
```

### 避免不必要的重建

```dart
// 使用 const
const Text('Static text')

// 使用 child 参数
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  child: const ExpensiveWidget(), // 不会重建
)

// 使用 Builder 分离作用域
Builder(
  builder: (context) {
    final theme = Theme.of(context);
    return Text('Style: ${theme.primaryColor}');
  },
)
```

## 平台集成

### 平台检查

```dart
import 'dart:io' show Platform;

if (Platform.isIOS) {
  // iOS 特定代码
} else if (Platform.isAndroid) {
  // Android 特定代码
}

// 使用 Theme
MaterialApp(
  theme: ThemeData(
    platform: TargetPlatform.iOS,
  ),
);
```

### MethodChannel

```dart
// Dart 端
class NativeService {
  static const channel = MethodChannel('com.example/native');

  Future<String> getDeviceId() async {
    try {
      return await channel.invokeMethod('getDeviceId');
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  Future<void> showToast(String message) async {
    await channel.invokeMethod('showToast', {'message': message});
  }
}

// Android (Kotlin)
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example/native")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getDeviceId" -> {
            result.success(Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID))
          }
          "showToast" -> {
            val message = call.argument<String>("message")
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}

// iOS (Swift)
class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example/native", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "getDeviceId":
        result.success(UIDevice.current.identifierForVendor?.uuidString)
      case "showToast":
        // iOS 没有 Toast，使用其他方式
        result.success(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 测试

### Widget 测试

```dart
void main() {
  testWidgets('Counter increments', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CounterWidget()),
    );

    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
  });
}
```

### 单元测试

```dart
void main() {
  group('CounterNotifier', () {
    test('initial value is 0', () {
      final counter = CounterNotifier();
      expect(counter.state, 0);
    });

    test('increment increases value', () {
      final counter = CounterNotifier();
      counter.increment();
      expect(counter.state, 1);
    });
  });
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| StatelessWidget | 无状态 UI |
| StatefulWidget | 有状态 UI |
| Provider | 简单状态管理 |
| Riverpod | 现代状态管理 |
| BLoC | 复杂状态管理 |
| FutureBuilder | 异步数据 |
| StreamBuilder | 实时数据 |

**记住**：Flutter 的核心是 Widget 组合。保持 Widget 小而专注，使用 const 优化性能，选择适合项目复杂度的状态管理方案。
