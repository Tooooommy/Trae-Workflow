# 小程序模式

## 架构模式

### MVC

```
pages/
├── model/      # 数据模型
├── view/       # 视图
├── controller/ # 控制器
```

### 模块化

```
utils/
├── request.ts  # 网络请求
├── storage.ts # 本地存储
├── auth.ts    # 认证
└── index.ts   # 导出
```

## 设计模式

- 单例: 全局 store
- 观察者: 数据监听 observers
- 策略: 不同业务使用不同 API
