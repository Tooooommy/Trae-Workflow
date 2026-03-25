# 微信小程序

## 命名规范

| 类型 | 规则       | 示例        |
| ---- | ---------- | ----------- |
| 页面 | kebab-case | user-info   |
| 组件 | PascalCase | UserCard    |
| 方法 | camelCase  | getUserInfo |

## 文件规范

- 页面 4 件套：.ts/.js, .wxml, .wxss, .json
- 组件 3 件套：.ts/.js, .wxml, .json

## 生命周期

| 阶段     | 方法     |
| -------- | -------- |
| 加载     | onLoad   |
| 显示     | onShow   |
| 渲染完成 | onReady  |
| 隐藏     | onHide   |
| 卸载     | onUnload |

## 性能优化

- 减少 setData 调用频率
- 列表渲染使用 key
- 图片使用 CDN 懒加载

## 安全

- 禁止存储密钥
- 使用 wx.login 获取 session
- 接口加签名防篡改
