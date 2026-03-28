# GitHub 上传指南

本指南说明如何将 Trae Workflow 项目上传到 GitHub。

## 前置要求

- Git 已安装（2.0+）
- GitHub 账户

## 步骤 1：在 GitHub 上创建仓库

### 方式 A：通过 GitHub 网页创建

1. 登录 [GitHub](https://github.com)
2. 点击右上角的 `+` 号，选择 `New repository`
3. 填写仓库信息：
   - **Repository name**: `Trae-Workflow`
   - **Description**: `Trae Workflow - AI 编码助手配置，基于 Skills-Rules 双层架构`
   - **Public/Private**: 选择公开或私有
   - **不要勾选**：Add a README file、Add .gitignore、Choose a license
4. 点击 `Create repository`

### 方式 B：使用 GitHub CLI

```bash
# 安装 GitHub CLI
# Windows: winget install GitHub.cli
# macOS: brew install gh
# Linux: sudo apt install gh

# 登录 GitHub
gh auth login

# 创建仓库
gh repo create Trae-Workflow --public --description "Trae Workflow - AI 编码助手配置"
```

## 步骤 2：配置 Git 用户信息

```bash
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"

# 验证配置
git config --global --list
```

## 步骤 3：初始化本地仓库

```bash
# 进入项目目录
cd "Trae Workflow"

# 初始化 Git（如果还没有）
git init

# 添加所有文件
git add .

# 查看将要提交的文件
git status
```

## 步骤 4：创建首次提交

```bash
git commit -m "feat: initial commit - Trae Workflow project

- Add 58+ skills
- Add 12 expert templates
- Add user rules
- Add CLI tool
- Add installation scripts"
```

## 步骤 5：连接远程仓库

```bash
# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/Trae-Workflow.git

# 验证远程仓库
git remote -v
```

## 步骤 6：推送到 GitHub

```bash
git branch -M main
git push -u origin main
```

## 完整命令汇总

```bash
# 1. 进入项目目录
cd "Trae Workflow"

# 2. 配置 Git（如果需要）
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"

# 3. 初始化仓库
git init

# 4. 添加所有文件
git add .

# 5. 创建提交
git commit -m "feat: initial commit - Trae Workflow project"

# 6. 添加远程仓库
git remote add origin https://github.com/YOUR_USERNAME/Trae-Workflow.git

# 7. 推送到 GitHub
git branch -M main
git push -u origin main
```

## 后续更新

```bash
# 查看修改状态
git status

# 添加修改的文件
git add .

# 创建提交
git commit -m "feat: add new feature"

# 推送到 GitHub
git push
```

## 常见问题

### 问题 1：推送时需要认证

**解决方案**：使用 Personal Access Token

1. 访问 GitHub → Settings → Developer settings → Personal access tokens
2. 创建新的 Token，勾选 `repo` 权限
3. 推送时使用 Token 作为密码

### 问题 2：远程仓库已存在内容

**解决方案**：强制推送（谨慎使用）

```bash
git push -u origin main --force
```

### 问题 3：文件太大

**解决方案**：使用 Git LFS

```bash
git lfs install
git lfs track "*.zip"
git add .gitattributes
git commit -m "chore: add Git LFS tracking"
```

## 推荐的仓库设置

### 1. 添加仓库描述和主题

在仓库 Settings → General 中：

- Description: `Trae Workflow - AI 编码助手配置，基于 Skills-Rules 双层架构`
- Topics: `trae`, `ai`, `skills`, `workflow`, `configuration`

### 2. 添加 LICENSE 文件

```bash
# 创建 MIT License
echo "MIT License

Copyright (c) 2024 Trae Workflow

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE." > LICENSE
```

## 相关资源

- [Git 官方文档](https://git-scm.com/doc)
- [GitHub 文档](https://docs.github.com)
- [Conventional Commits](https://www.conventionalcommits.org)
