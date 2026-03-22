---
alwaysApply: false
globs:
  - '**/project.config.json'
  - '**/app.json'
---

# 微信小程序项目规范与指南

> 基于微信小程序原生开发的规范。

## 项目总览

- 技术栈: WXML, WXSS, JavaScript/TypeScript
- 架构: 双线程模型（渲染层 + 逻辑层）

## 关键规则

### 项目结构

```
miniprogram/
├── app.js                  # 小程序入口
├── app.json                # 全局配置
├── app.wxss                # 全局样式
├── project.config.json     # 项目配置
├── sitemap.json            # 站点地图
├── pages/
│   ├── index/
│   │   ├── index.js
│   │   ├── index.json
│   │   ├── index.wxml
│   │   └── index.wxss
│   └── user/
├── components/
│   └── custom-tabbar/
├── utils/
│   ├── request.js
│   └── util.js
├── services/
│   └── api.js
├── assets/
│   └── images/
└── subpackages/            # 分包
    └── packageA/
```

### 全局配置

```json
{
  "pages": ["pages/index/index", "pages/user/user"],
  "window": {
    "navigationBarTitleText": "小程序",
    "navigationBarBackgroundColor": "#ffffff",
    "navigationBarTextStyle": "black",
    "backgroundColor": "#f5f5f5"
  },
  "tabBar": {
    "color": "#999",
    "selectedColor": "#07c160",
    "list": [
      {
        "pagePath": "pages/index/index",
        "text": "首页",
        "iconPath": "assets/icons/home.png",
        "selectedIconPath": "assets/icons/home-active.png"
      },
      {
        "pagePath": "pages/user/user",
        "text": "我的",
        "iconPath": "assets/icons/user.png",
        "selectedIconPath": "assets/icons/user-active.png"
      }
    ]
  },
  "subpackages": [{ "root": "subpackages/packageA", "pages": ["detail/detail"] }],
  "lazyCodeLoading": "requiredComponents"
}
```

### 页面定义

```javascript
Page({
  data: {
    list: [],
    loading: false,
  },

  onLoad(options) {
    this.loadData(options.id);
  },

  onPullDownRefresh() {
    this.loadData();
  },

  onReachBottom() {
    this.loadMore();
  },

  async loadData(id) {
    this.setData({ loading: true });
    try {
      const list = await api.getList(id);
      this.setData({ list });
    } finally {
      this.setData({ loading: false });
      wx.stopPullDownRefresh();
    }
  },
});
```

### 组件定义

```javascript
Component({
  options: {
    multipleSlots: true,
    styleIsolation: 'apply-shared',
  },

  properties: {
    title: {
      type: String,
      value: '',
    },
    show: {
      type: Boolean,
      value: false,
    },
  },

  data: {
    visible: false,
  },

  lifetimes: {
    attached() {
      this.setData({ visible: this.properties.show });
    },
  },

  methods: {
    handleClose() {
      this.triggerEvent('close');
    },
  },
});
```

## 环境配置

```json
// project.config.json
{
  "miniprogramRoot": "miniprogram/",
  "compileType": "miniprogram",
  "setting": {
    "es6": true,
    "minified": true,
    "enhance": true
  },
  "appid": "your-appid"
}
```

## 开发命令

```bash
# 微信开发者工具
# 导入项目后自动编译

# CLI 编译
npm run build:weapp

# 上传代码
npm run upload
```
