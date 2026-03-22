---
name: ci-cd-patterns
description: CI/CD 流水线模式、自动化部署和持续交付最佳实践。适用于所有需要自动化的项目。
---

# CI/CD 流水线模式

用于构建高效、可靠和安全的持续集成与持续交付流水线的模式与最佳实践。

## 何时激活

- 设计 CI/CD 流水线
- 编写流水线配置
- 优化构建和部署流程
- 实现自动化测试和部署

## 技术栈版本

| 技术           | 最低版本 | 推荐版本 |
| -------------- | -------- | -------- |
| GitHub Actions | N/A      | 最新     |
| GitLab CI      | 15+      | 最新     |
| Docker         | 24+      | 27+      |
| kubectl        | 1.28+    | 最新     |
| Helm           | 3.12+    | 最新     |

## 核心原则

### 1. 流水线阶段

```
代码提交 → 构建 → 测试 → 安全扫描 → 部署 → 监控
    ↓        ↓       ↓          ↓         ↓       ↓
  Lint    Compile  Unit      SAST     Staging  Alerts
  Format  Package  Integ     DAST     Prod     Metrics
```

### 2. 最佳实践

- **快速反馈**：构建和测试应在 10 分钟内完成
- **幂等性**：多次执行结果相同
- **可重复性**：相同输入产生相同输出
- **可观测性**：清晰的日志和状态
- **失败安全**：失败时自动回滚

## GitHub Actions 模式

### 基础工作流

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test:coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
```

### Docker 构建和推送

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha,prefix=

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### 部署到 Kubernetes

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Set up kubectl
        uses: azure/setup-kubectl@v3

      - name: Configure kubeconfig
        run: |
          mkdir -p ~/.kube
          echo "${{ secrets.KUBE_CONFIG }}" | base64 -d > ~/.kube/config

      - name: Deploy
        run: |
          kubectl apply -f k8s/
          kubectl rollout status deployment/myapp -n production

      - name: Verify deployment
        run: |
          kubectl wait --for=condition=available --timeout=300s deployment/myapp -n production
```

## GitLab CI 模式

### 基础配置

```yaml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  NODE_VERSION: '20'

.node_template:
  image: node:${NODE_VERSION}
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
  before_script:
    - npm ci

lint:
  extends: .node_template
  stage: lint
  script:
    - npm run lint
    - npm run typecheck

test:
  extends: .node_template
  stage: test
  script:
    - npm run test:coverage
  coverage: '/Lines\s*:\s*(\d+.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build:
  extends: .node_template
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy_staging:
  stage: deploy
  environment: staging
  script:
    - echo "Deploying to staging..."
  only:
    - develop

deploy_production:
  stage: deploy
  environment: production
  script:
    - echo "Deploying to production..."
  only:
    - main
  when: manual
```

## 部署策略

### 蓝绿部署

```yaml
deploy_blue_green:
  script:
    - |
      # 确定当前活跃环境
      CURRENT=$(kubectl get service myapp -o jsonpath='{.spec.selector.version}')

      # 部署到非活跃环境
      if [ "$CURRENT" = "blue" ]; then
        TARGET="green"
      else
        TARGET="blue"
      fi

      kubectl apply -f k8s/deployment-${TARGET}.yaml
      kubectl wait --for=condition=available deployment/myapp-${TARGET}

      # 切换流量
      kubectl patch service myapp -p '{"spec":{"selector":{"version":"'$TARGET'"}}}'

      # 清理旧环境
      kubectl delete deployment myapp-${CURRENT} --ignore-not-found
```

### 金丝雀发布

```yaml
deploy_canary:
  script:
    - |
      # 部署金丝雀版本 (10% 流量)
      kubectl apply -f k8s/canary.yaml

      # 监控指标
      for i in {1..10}; do
        ERROR_RATE=$(curl -s http://prometheus/api/v1/query?query=error_rate | jq -r '.data.result[0].value[1]')
        if [ $(echo "$ERROR_RATE > 0.01" | bc) -eq 1 ]; then
          echo "Error rate too high, rolling back"
          kubectl delete -f k8s/canary.yaml
          exit 1
        fi
        sleep 60
      done

      # 逐步增加流量
      kubectl patch deployment myapp-canary -p '{"spec":{"replicas":3}}'
```

## 安全扫描

### SAST (静态分析)

```yaml
sast:
  stage: test
  script:
    - |
      # Semgrep
      docker run --rm -v $(pwd):/src semgrep/semgrep semgrep --config=auto --json --output=report.json
  artifacts:
    reports:
      sast: report.json
```

### 依赖扫描

```yaml
dependency_scan:
  stage: test
  script:
    - npm audit --audit-level=high
    - npx better-npm-audit audit
  allow_failure: true
```

### 容器扫描

```yaml
container_scan:
  stage: test
  script:
    - |
      docker build -t myapp:scan .
      docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
        aquasec/trivy image myapp:scan
```

## 环境管理

### 多环境配置

```yaml
.deploy_template:
  script:
    - kubectl apply -k k8s/overlays/${ENVIRONMENT}
    - kubectl rollout status deployment/myapp -n ${ENVIRONMENT}

deploy_dev:
  extends: .deploy_template
  variables:
    ENVIRONMENT: dev
  environment: development
  only: [develop]

deploy_staging:
  extends: .deploy_template
  variables:
    ENVIRONMENT: staging
  environment: staging
  only: [main]

deploy_production:
  extends: .deploy_template
  variables:
    ENVIRONMENT: prod
  environment: production
  only: [main]
  when: manual
```

### 环境变量管理

```yaml
# GitHub Actions
env:
  NODE_ENV: production

jobs:
  deploy:
    environment: production
    env:
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
      API_KEY: ${{ secrets.API_KEY }}
```

## 缓存优化

### 依赖缓存

```yaml
# GitHub Actions
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# GitLab CI
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/
```

### Docker 层缓存

```yaml
- name: Build with cache
  uses: docker/build-push-action@v5
  with:
    context: .
    cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:cache
    cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:cache,mode=max
```

## 快速参考

| 阶段    | 任务          | 工具             |
| ------- | ------------- | ---------------- |
| Lint    | 代码检查      | ESLint, Prettier |
| Test    | 单元/集成测试 | Jest, Vitest     |
| Build   | 构建产物      | Webpack, Vite    |
| Scan    | 安全扫描      | Trivy, Semgrep   |
| Deploy  | 部署应用      | kubectl, Helm    |
| Monitor | 监控告警      | Prometheus       |

**记住**：流水线应该是快速、可靠和可重复的。每个阶段都应该有明确的失败条件和回滚策略。
