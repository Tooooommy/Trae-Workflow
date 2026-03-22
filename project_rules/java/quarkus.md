---
alwaysApply: false
globs:
  - '**/pom.xml'
  - '**/build.gradle'
  - '**/application.properties'
---

# Quarkus 项目规范与指南

> 基于 Quarkus 的云原生 Java 应用开发规范。

## 项目总览

- 技术栈: Java 21+, Quarkus 3, Hibernate ORM, PostgreSQL
- 架构: 云原生, 响应式

## 关键规则

### 项目结构

```
src/
├── main/
│   ├── java/org/example/
│   │   ├── GreetingResource.java
│   │   ├── user/
│   │   │   ├── UserResource.java
│   │   │   ├── UserService.java
│   │   │   ├── UserRepository.java
│   │   │   └── User.java
│   │   └── config/
│   │       └── SecurityConfig.java
│   └── resources/
│       └── application.properties
└── test/
    └── java/org/example/
```

### Resource

```java
@Path("/api/v1/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UserResource {

    @Inject
    UserService userService;

    @POST
    @ResponseStatus(HttpStatus.CREATED)
    public User create(@Valid CreateUserRequest request) {
        return userService.create(request);
    }

    @GET
    @Path("/{id}")
    public User getById(@PathParam("id") Long id) {
        return userService.findById(id);
    }

    @GET
    public List<User> list() {
        return userService.findAll();
    }
}
```

### Panache Repository

```java
@ApplicationScoped
public class UserRepository implements PanacheRepository<User> {
    public Optional<User> findByEmail(String email) {
        return find("email", email).firstResultOptional();
    }

    public List<User> findActive() {
        return list("active", true);
    }
}
```

## 环境变量

```properties
quarkus.datasource.db-kind=postgresql
quarkus.datasource.jdbc.url=${DATABASE_URL}
quarkus.datasource.username=${DB_USER}
quarkus.datasource.password=${DB_PASSWORD}
quarkus.http.port=8080
mp.jwt.verify.secretkey=${JWT_SECRET}
```

## 开发命令

```bash
./mvnw quarkus:dev           # 开发模式
./mvnw clean package         # 构建
./mvnw test                  # 测试
java -jar target/quarkus-app/quarkus-run.jar  # 运行
```
