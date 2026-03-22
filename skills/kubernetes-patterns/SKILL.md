---
name: kubernetes-patterns
description: Kubernetes 部署模式、资源管理、服务发现和可观测性最佳实践。适用于 K8s 部署项目。
---

# Kubernetes 部署模式

用于构建可扩展、高可用和可维护 Kubernetes 应用的模式与最佳实践。

## 何时激活

- 设计 K8s 部署配置
- 编写 Kubernetes manifests
- 排查 K8s 部署问题
- 优化 K8s 资源配置

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Kubernetes | 1.28+ | 1.31+ |
| kubectl | 1.28+ | 最新 |
| Helm | 3.12+ | 最新 |
| kustomize | 5.0+ | 最新 |
| cert-manager | 1.13+ | 最新 |

## 核心概念

### 1. 控制器层次

```
Deployment → ReplicaSet → Pod
     ↓
StatefulSet (有状态应用)
     ↓
DaemonSet (每节点一个)
     ↓
Job / CronJob (批处理)
```

### 2. 服务发现

```
Service Types:
├── ClusterIP    (内部服务)
├── NodePort     (节点端口)
├── LoadBalancer (云负载均衡)
└── ExternalName (外部服务别名)
```

## 部署模式

### 基础 Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: LOG_LEVEL
          value: "info"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
```

### StatefulSet (有状态应用)

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: standard
      resources:
        requests:
          storage: 10Gi
```

### HorizontalPodAutoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## 服务与网络

### Service 配置

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-headless
spec:
  type: ClusterIP
  clusterIP: None  # Headless service
  selector:
    app: myapp
  ports:
  - port: 8080
```

### Ingress 配置

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 80
```

### NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-network-policy
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
```

## 配置管理

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  application.yml: |
    server:
      port: 8080
    database:
      host: postgres
      port: 5432
    logging:
      level: info
---
# 在 Pod 中使用
spec:
  containers:
  - name: myapp
    volumeMounts:
    - name: config
      mountPath: /config
  volumes:
  - name: config
    configMap:
      name: myapp-config
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
stringData:
  password: supersecret
  username: admin
---
# 使用
env:
- name: DB_USERNAME
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: username
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

## 可观测性

### 资源限制

```yaml
resources:
  requests:        # 调度依据
    cpu: 100m      # 0.1 核
    memory: 128Mi
  limits:          # 最大限制
    cpu: 500m      # 0.5 核
    memory: 512Mi
```

### 健康检查

```yaml
livenessProbe:     # 存活检查 - 失败则重启
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:    # 就绪检查 - 失败则从服务移除
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  failureThreshold: 3

startupProbe:      # 启动检查 - 慢启动应用
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 30  # 最多等待 300s
```

### 日志收集

```yaml
# 标准输出日志自动收集
# 结构化日志格式
spec:
  containers:
  - name: myapp
    env:
    - name: LOG_FORMAT
      value: json
    - name: LOG_OUTPUT
      value: stdout
```

## 安全最佳实践

### Pod Security

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
  containers:
  - name: myapp
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myapp-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: myapp-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: myapp-rolebinding
subjects:
- kind: ServiceAccount
  name: myapp-sa
roleRef:
  kind: Role
  name: myapp-role
  apiGroup: rbac.authorization.k8s.io
```

## 常用命令

```bash
# 部署
kubectl apply -f deployment.yaml
kubectl rollout status deployment/myapp

# 扩缩容
kubectl scale deployment myapp --replicas=5
kubectl autoscale deployment myapp --min=2 --max=10 --cpu-percent=70

# 更新
kubectl set image deployment/myapp myapp=myapp:v2.0.0
kubectl rollout undo deployment/myapp
kubectl rollout history deployment/myapp

# 调试
kubectl logs -f deployment/myapp
kubectl exec -it pod/myapp-xxx -- /bin/sh
kubectl describe pod myapp-xxx
kubectl get events --sort-by='.lastTimestamp'

# 资源
kubectl top pods
kubectl top nodes
kubectl describe resourcequotas
```

## 快速参考

| 资源 | 用途 |
|------|------|
| Deployment | 无状态应用 |
| StatefulSet | 有状态应用 |
| DaemonSet | 每节点一个 |
| Job | 一次性任务 |
| CronJob | 定时任务 |
| Service | 服务发现 |
| Ingress | HTTP 路由 |
| ConfigMap | 配置数据 |
| Secret | 敏感数据 |
| HPA | 自动扩缩容 |

**记住**：Kubernetes 配置应该版本控制，使用 Kustomize 或 Helm 管理多环境配置。
