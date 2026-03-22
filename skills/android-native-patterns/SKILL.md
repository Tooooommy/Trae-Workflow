---
name: android-native-patterns
description: Android 原生开发、Jetpack Compose、MVVM 架构和 Kotlin 协程最佳实践。适用于所有 Android 原生项目。
---

# Android 原生开发模式

用于构建高性能、可维护 Android 应用的 Kotlin 模式与最佳实践。

## 何时激活

- 编写新的 Android 原生应用
- 设计 Android 架构模式
- 实现 Jetpack Compose 界面
- 处理 Android 协程和数据

## 技术栈版本

| 技术            | 最低版本 | 推荐版本 |
| --------------- | -------- | -------- |
| Kotlin          | 1.9+     | 2.0+     |
| Android SDK     | 34+      | 最新     |
| Jetpack Compose | 1.6+     | 最新     |
| Hilt            | 2.50+    | 最新     |
| Coroutines      | 1.8+     | 最新     |

## 核心原则

### 1. Jetpack Compose 优先

```kotlin
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle

@Composable
fun UserListScreen(
    viewModel: UserViewModel = hiltViewModel(),
    onUserClick: (User) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Users") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer
                )
            )
        }
    ) { padding ->
        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding),
                    contentAlignment = androidx.compose.ui.Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            uiState.error != null -> {
                ErrorView(
                    message = uiState.error!!,
                    onRetry = { viewModel.loadUsers() },
                    modifier = Modifier.padding(padding)
                )
            }
            else -> {
                UserList(
                    users = uiState.users,
                    onUserClick = onUserClick,
                    modifier = Modifier.padding(padding)
                )
            }
        }
    }
}

@Composable
fun UserList(
    users: List<User>,
    onUserClick: (User) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(users, key = { it.id }) { user ->
            UserCard(
                user = user,
                onClick = { onUserClick(user) }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            AsyncImage(
                model = user.avatarUrl,
                contentDescription = null,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape)
            )
            Column {
                Text(
                    text = user.name,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = user.email,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
```

### 2. MVVM 架构

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import javax.inject.Inject

data class UserUiState(
    val users: List<User> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class UserViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(UserUiState())
    val uiState: StateFlow<UserUiState> = _uiState.asStateFlow()

    init {
        loadUsers()
    }

    fun loadUsers() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }

            userRepository.getUsers()
                .onSuccess { users ->
                    _uiState.update {
                        it.copy(users = users, isLoading = false)
                    }
                }
                .onFailure { error ->
                    _uiState.update {
                        it.copy(error = error.message, isLoading = false)
                    }
                }
        }
    }

    fun refresh() {
        loadUsers()
    }
}
```

### 3. 依赖注入 (Hilt)

```kotlin
// Application
@HiltAndroidApp
class MyApplication : Application()

// Module
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(LoggingInterceptor())
            .connectTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(client: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl("https://api.example.com")
            .client(client)
            .addConverterFactory(Json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }
}

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "app_database"
        ).build()
    }

    @Provides
    fun provideUserDao(database: AppDatabase): UserDao {
        return database.userDao()
    }
}

// Activity
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyAppTheme {
                // Content
            }
        }
    }
}
```

## 协程模式

### Flow

```kotlin
class UserRepository @Inject constructor(
    private val apiService: ApiService,
    private val userDao: UserDao
) {
    fun getUsers(): Flow<List<User>> = channelFlow {
        // 先发送缓存数据
        val cached = userDao.getAll()
        if (cached.isNotEmpty()) {
            send(cached)
        }

        // 从网络获取最新数据
        try {
            val remote = apiService.getUsers()
            userDao.insertAll(remote)
            send(remote)
        } catch (e: Exception) {
            if (cached.isEmpty()) {
                throw e
            }
        }
    }

    fun getUser(id: String): Flow<User> = flow {
        emit(apiService.getUser(id))
    }
        .catch { e ->
            val cached = userDao.getById(id)
            if (cached != null) {
                emit(cached)
            } else {
                throw e
            }
        }
}

// 在 ViewModel 中使用
fun observeUsers() {
    userRepository.getUsers()
        .onStart { _uiState.update { it.copy(isLoading = true) } }
        .onEach { users ->
            _uiState.update { it.copy(users = users, isLoading = false) }
        }
        .catch { e ->
            _uiState.update { it.copy(error = e.message, isLoading = false) }
        }
        .launchIn(viewModelScope)
}
```

### 并发操作

```kotlin
class DashboardRepository @Inject constructor(
    private val userRepository: UserRepository,
    private val orderRepository: OrderRepository,
    private val notificationRepository: NotificationRepository
) {
    suspend fun loadDashboard(): Dashboard = coroutineScope {
        val userDeferred = async { userRepository.getCurrentUser() }
        val ordersDeferred = async { orderRepository.getRecentOrders() }
        val notificationsDeferred = async { notificationRepository.getNotifications() }

        Dashboard(
            user = userDeferred.await(),
            orders = ordersDeferred.await(),
            notifications = notificationsDeferred.await()
        )
    }
}
```

## 数据持久化

### Room

```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    val name: String,
    val email: String,
    val avatarUrl: String?,
    val createdAt: Long = System.currentTimeMillis()
)

@Dao
interface UserDao {
    @Query("SELECT * FROM users ORDER BY createdAt DESC")
    fun getAll(): Flow<List<UserEntity>>

    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun getById(id: String): UserEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(users: List<UserEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(user: UserEntity)

    @Delete
    suspend fun delete(user: UserEntity)

    @Query("DELETE FROM users")
    suspend fun deleteAll()
}

@Database(entities = [UserEntity::class, OrderEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun orderDao(): OrderDao
}

// 类型转换
class Converters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? = value?.let { Date(it) }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? = date?.time
}
```

### DataStore

```kotlin
// Preferences DataStore
val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

class SettingsRepository @Inject constructor(
    private val context: Context
) {
    private object PreferencesKeys {
        val DARK_MODE = booleanPreferencesKey("dark_mode")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        val USER_ID = stringPreferencesKey("user_id")
    }

    val darkMode: Flow<Boolean> = context.dataStore.data
        .map { preferences -> preferences[PreferencesKeys.DARK_MODE] ?: false }

    val notificationsEnabled: Flow<Boolean> = context.dataStore.data
        .map { preferences -> preferences[PreferencesKeys.NOTIFICATIONS_ENABLED] ?: true }

    suspend fun setDarkMode(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.DARK_MODE] = enabled
        }
    }

    suspend fun setNotificationsEnabled(enabled: Boolean) {
        context.dataStore.edit { preferences ->
            preferences[PreferencesKeys.NOTIFICATIONS_ENABLED] = enabled
        }
    }
}

// Proto DataStore
@Serializable
data class UserPreferences(
    @ProtoNumber(1) val userId: String = "",
    @ProtoNumber(2) val theme: Theme = Theme.SYSTEM,
    @ProtoNumber(3) val notificationsEnabled: Boolean = true
)

val Context.userPreferencesStore: DataStore<UserPreferences> by dataStore(
    fileName = "user_preferences.pb",
    serializer = UserPreferencesSerializer()
)
```

## 网络请求

### Retrofit + Kotlin Serialization

```kotlin
interface ApiService {
    @GET("users")
    suspend fun getUsers(): List<User>

    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: String): User

    @POST("users")
    suspend fun createUser(@Body user: CreateUserRequest): User

    @PUT("users/{id}")
    suspend fun updateUser(@Path("id") id: String, @Body user: UpdateUserRequest): User

    @DELETE("users/{id}")
    suspend fun deleteUser(@Path("id") id: String)

    @GET("users")
    suspend fun searchUsers(@Query("q") query: String): List<User>
}

// 错误处理
sealed class NetworkResult<out T> {
    data class Success<T>(val data: T) : NetworkResult<T>()
    data class Error(val message: String, val code: Int? = null) : NetworkResult<Nothing>()
    data object Loading : NetworkResult<Nothing>()
}

suspend inline fun <reified T> safeApiCall(
    crossinline apiCall: suspend () -> T
): NetworkResult<T> {
    return try {
        NetworkResult.Success(apiCall())
    } catch (e: HttpException) {
        NetworkResult.Error(
            message = e.message(),
            code = e.code()
        )
    } catch (e: IOException) {
        NetworkResult.Error("Network error: ${e.message}")
    } catch (e: Exception) {
        NetworkResult.Error("Unknown error: ${e.message}")
    }
}
```

## 导航

### Compose Navigation

```kotlin
@Serializable
object UserList

@Serializable
data class UserDetail(val userId: String)

@Serializable
object Settings

@Composable
fun AppNavigation() {
    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = UserList
    ) {
        composable<UserList> {
            UserListScreen(
                onUserClick = { user ->
                    navController.navigate(UserDetail(user.id))
                },
                onSettingsClick = {
                    navController.navigate(Settings)
                }
            )
        }

        composable<UserDetail> { backStackEntry ->
            val userDetail: UserDetail = backStackEntry.toRoute()
            UserDetailScreen(
                userId = userDetail.userId,
                onBack = { navController.popBackStack() }
            )
        }

        composable<Settings> {
            SettingsScreen(
                onBack = { navController.popBackStack() }
            )
        }
    }
}

// Deep Link
@Serializable
data class ProductDetail(
    val productId: String,
    val referrer: String? = null
)

composable<ProductDetail>(
    deepLinks = listOf(
        navDeepLink<ProductDetail>(
            basePath = "myapp://product"
        )
    )
) { backStackEntry ->
    val product: ProductDetail = backStackEntry.toRoute()
    ProductDetailScreen(product.productId)
}
```

## 测试

### 单元测试

```kotlin
import kotlinx.coroutines.test.*
import org.junit.Assert.*
import org.junit.Test

class UserViewModelTest {
    @Test
    fun `loadUsers updates uiState with users`() = runTest {
        // Given
        val mockUsers = listOf(
            User(id = "1", name = "Alice", email = "alice@example.com"),
            User(id = "2", name = "Bob", email = "bob@example.com")
        )
        val mockRepository = MockUserRepository().apply {
            usersToReturn = mockUsers
        }
        val viewModel = UserViewModel(mockRepository)

        // When
        viewModel.loadUsers()
        advanceUntilIdle()

        // Then
        val uiState = viewModel.uiState.value
        assertFalse(uiState.isLoading)
        assertEquals(mockUsers, uiState.users)
        assertNull(uiState.error)
    }

    @Test
    fun `loadUsers handles error`() = runTest {
        // Given
        val mockRepository = MockUserRepository().apply {
            errorToThrow = RuntimeException("Network error")
        }
        val viewModel = UserViewModel(mockRepository)

        // When
        viewModel.loadUsers()
        advanceUntilIdle()

        // Then
        val uiState = viewModel.uiState.value
        assertFalse(uiState.isLoading)
        assertTrue(uiState.users.isEmpty())
        assertEquals("Network error", uiState.error)
    }
}

class MockUserRepository : UserRepository {
    var usersToReturn: List<User> = emptyList()
    var errorToThrow: Throwable? = null

    override suspend fun getUsers(): Result<List<User>> {
        errorToThrow?.let { return Result.failure(it) }
        return Result.success(usersToReturn)
    }
}
```

### UI 测试

```kotlin
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import org.junit.Rule
import org.junit.Test

class UserListScreenTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun displaysLoadingIndicator_whenLoading() {
        composeTestRule.setContent {
            UserListScreen(
                viewModel = UserViewModel().apply {
                    // Set loading state
                }
            )
        }

        composeTestRule.onNodeWithText("Loading").assertIsDisplayed()
    }

    @Test
    fun displaysUsers_whenLoaded() {
        val testUsers = listOf(
            User(id = "1", name = "Alice", email = "alice@example.com"),
            User(id = "2", name = "Bob", email = "bob@example.com")
        )

        composeTestRule.setContent {
            UserListScreen(
                viewModel = UserViewModel().apply {
                    // Set loaded state with test users
                }
            )
        }

        composeTestRule.onNodeWithText("Alice").assertIsDisplayed()
        composeTestRule.onNodeWithText("Bob").assertIsDisplayed()
    }

    @Test
    fun clicksUser_navigatesToDetail() {
        var clickedUser: User? = null

        composeTestRule.setContent {
            UserListScreen(
                viewModel = UserViewModel(),
                onUserClick = { clickedUser = it }
            )
        }

        composeTestRule.onNodeWithText("Alice").performClick()

        assertNotNull(clickedUser)
    }
}
```

## 快速参考

| 模式               | 用途             |
| ------------------ | ---------------- |
| @Composable        | 可组合函数       |
| StateFlow          | 状态流           |
| viewModelScope     | ViewModel 作用域 |
| Hilt               | 依赖注入         |
| Room               | 数据库           |
| DataStore          | 偏好设置         |
| Navigation Compose | 类型安全导航     |

**记住**：Jetpack Compose 和 Kotlin 协程是 Android 开发的现代方式。使用 MVVM 架构，Hilt 依赖注入，充分利用 Flow 和协程进行异步编程。
