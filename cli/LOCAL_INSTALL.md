# Trae Workflow CLI 本地安装指南

本指南说明如何在本地安装和测试 Trae Workflow CLI。

## 前置要求

- **Node.js**：14.0 或更高版本
- **npm**：随 Node.js 安装

## 安装步骤

### 步骤 1：进入 CLI 目录

```bash
cd "c:\Users\Administrator\Desktop\traeconf\Trae Workflow\cli"
```

### 步骤 2：安装依赖

```bash
npm install
```

这会安装 package.json 中定义的所有依赖项：
- axios
- chalk
- commander
- ora
- fs-extra
- tar

### 步骤 3：本地链接（推荐）

```bash
npm link
```

这会在全局创建一个符号链接，使 `traew` 命令在系统任何位置都可用。

### 步骤 4：验证安装

```bash
traew version
```

应该显示：`Trae Workflow CLI v1.0.0`

## 使用方法

### 安装 Trae Workflow

```bash
# 从默认仓库安装
traew install

# 从指定仓库安装
traew install username/repo

# 安装时备份现有配置
traew install --backup

# 跳过某些组件
traew install --skip-mcp --skip-skills
```

### 其他命令

```bash
# 更新到最新版本
traew update

# 查看当前版本
traew version

# 查看帮助
traew install --help
```

## 直接运行（不使用 npm link）

如果不想使用 npm link，可以直接运行：

```bash
# Windows
node "c:\Users\Administrator\Desktop\traeconf\Trae Workflow\cli\bin\trae.js" install

# Linux/macOS
node cli/bin/trae.js install
```

## 开发模式

### 修改代码后测试

1. 修改 CLI 代码
2. 重新链接（如果使用 npm link）：
   ```bash
   npm link
   ```
3. 测试修改后的功能

### 调试模式

```bash
# 查看详细输出
node --inspect cli/bin/trae.js install
```

## 卸载本地链接

```bash
npm unlink trae-workflow-cli
```

## 故障排除

### 问题：`traew` 命令未找到

**解决方案**：
1. 确认已运行 `npm link`
2. 检查 npm 全局路径：
   ```bash
   npm config get prefix
   ```
3. 确保 npm 全局 bin 目录在 PATH 中

### 问题：权限错误

**解决方案**：
```bash
# Windows（以管理员身份运行 PowerShell）
# Linux/macOS（使用 sudo）
sudo npm link
```

### 问题：依赖安装失败

**解决方案**：
```bash
# 清除 npm 缓存
npm cache clean --force

# 删除 node_modules 和 package-lock.json
rm -rf node_modules package-lock.json

# 重新安装
npm install
```

## 完整示例

```bash
# 1. 进入 CLI 目录
cd "c:\Users\Administrator\Desktop\traeconf\Trae Workflow\cli"

# 2. 安装依赖
npm install

# 3. 本地链接
npm link

# 4. 验证安装
traew version

# 5. 使用 CLI 安装 Trae Workflow
traew install --backup
```
