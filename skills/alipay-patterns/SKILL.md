---
name: alipay-patterns
description: 支付宝支付集成模式 - 电脑网站支付、手机网站支付、APP 支付、当面付及退款、查询等最佳实践。**必须激活当**：用户要求集成支付宝、处理支付或实现退款查询时。即使用户没有明确说"支付宝"，当涉及支付宝支付或移动支付时也应使用。
---

# 支付宝支付集成模式

> 电脑网站支付、手机网站支付、APP 支付、当面付及退款、查询等最佳实践

## 何时激活

- 集成支付宝支付功能
- 电脑网站支付 (Web)
- 手机网站支付 (H5)
- APP 支付 (iOS/Android)
- 当面付 (扫码)
- 支付退款处理
- 订单查询与管理

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| alipay-sdk | 4.35.0+  | 最新     |
| Node.js    | 16.0+    | 20.0+    |
| Redis      | 6.0+     | 7.0+     |

---

## 核心概念

### 支付流程

```mermaid
sequenceDiagram
    participant Merchant as 商户
    participant User as 用户
    participant Alipay as 支付宝

    Merchant->>User: 展示支付页面
    User->>Merchant: 选择支付宝支付
    Merchant->>Alipay: 构造并发送支付请求
    Alipay->>User: 展示收银台
    User->>Alipay: 完成支付
    Alipay->>Merchant: 异步通知支付结果
    Merchant->>Alipay: 验证签名并处理
    Alipay-->>Merchant: 返回 success
```

### 支付方式对比

| 支付方式     | productCode              | 适用场景        | 返回格式       |
| ------------ | ------------------------ | --------------- | -------------- |
| 电脑网站支付 | `FAST_INSTANT_TRADE_PAY` | PC 网页         | HTML 表单      |
| 手机网站支付 | `QUICK_WAP_WAY`          | H5/移动端网页   | HTML 表单      |
| APP 支付     | `QUICK_MSECURITY_PAY`    | iOS/Android SDK | 请求参数字符串 |
| 当面付       | `FAST_INSTANT_TRADE_PAY` | 扫码枪          | 直接返回结果   |

---

## 初始化

### SDK 初始化

```typescript
import AlipaySdk from 'alipay-sdk';

const alipay = new AlipaySdk({
  appId: process.env.ALIPAY_APP_ID!,
  privateKey: process.env.ALIPAY_PRIVATE_KEY!,
  alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY!,
  signType: 'RSA2',
  gateway: 'https://openapi.alipaydev.com/gateway.do', // 沙箱环境
  timeout: 30000,
});
```

### 环境配置

```typescript
const config = {
  development: {
    gateway: 'https://openapi.alipaydev.com/gateway.do',
    appId: process.env.ALIPAY_DEV_APP_ID,
  },
  production: {
    gateway: 'https://openapi.alipay.com/gateway.do',
    appId: process.env.ALIPAY_PROD_APP_ID,
  },
}[process.env.NODE_ENV || 'development'];
```

---

## 电脑网站支付 (Web)

### 构造支付请求

```typescript
async function createWebPayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.page.pay', {
    outTradeNo: orderId,
    productCode: 'FAST_INSTANT_TRADE_PAY',
    totalAmount: amount.toString(),
    subject,
    body: `订单 ${orderId} 的描述`,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
    returnUrl: `${process.env.BASE_URL}/payment/result`,
  });

  return result; // 返回 HTML 表单
}
```

### Express 路由

```typescript
import express from 'express';

const router = express.Router();

router.post('/pay', async (req, res) => {
  try {
    const { orderId, amount, subject } = req.body;

    // 参数验证
    if (!orderId || !amount || !subject) {
      res.status(400).json({ error: '缺少必要参数' });
      return;
    }

    const form = await createWebPayOrder(orderId, amount, subject);
    res.json({ form });
  } catch (error) {
    console.error('创建支付订单失败:', error);
    res.status(500).json({ error: '创建支付订单失败' });
  }
});
```

### 同步回调处理

```typescript
router.get('/return', async (req, res) => {
  try {
    const { out_trade_no, trade_no } = req.query;

    // 验证签名
    const signResult = alipay.checkNotifySign(req.query);
    if (!signResult) {
      res.status(403).send('签名验证失败');
      return;
    }

    // 更新订单状态
    await orderService.updateByTradeNo(out_trade_no, {
      status: 'PAID',
      alipayTradeNo: trade_no,
    });

    res.redirect('/order/success');
  } catch (error) {
    console.error('支付回调处理失败:', error);
    res.redirect('/order/failed');
  }
});
```

---

## 手机网站支付 (H5)

### H5 支付

```typescript
async function createH5PayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.wap.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_WAP_WAY',
    totalAmount: amount.toString(),
    subject,
    body: `订单 ${orderId} 的描述`,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
    quitUrl: `${process.env.BASE_URL}/payment/cancel`,
  });

  return result; // 返回 HTML 表单
}
```

### 唤起支付宝 App

```html
<!-- H5 页面中嵌入表单，用户点击后唤起支付宝 -->
<form id="alipay-form" method="post" action="https://openapi.alipay.com/gateway.do">
  <!-- 表单内容由 SDK 生成 -->
</form>
<script>
  document.getElementById('alipay-form').submit();
</script>
```

---

## APP 支付

### 服务端构造订单

```typescript
async function createAppPayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.app.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_MSECURITY_PAY',
    totalAmount: amount.toString(),
    subject,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
  });

  // 返回的是请求参数字符串，客户端直接使用
  return result;
}
```

### 服务端路由

```typescript
router.post('/app/pay', async (req, res) => {
  try {
    const { orderId, amount, subject } = req.body;
    const orderStr = await createAppPayOrder(orderId, amount, subject);
    res.json({ orderStr });
  } catch (error) {
    console.error('创建 APP 支付订单失败:', error);
    res.status(500).json({ error: '创建支付订单失败' });
  }
});
```

### 客户端调用 (iOS/Android)

```kotlin
// Android - 调用支付宝 SDK
val orderInfo = orderStr // 从服务端获取
AlipayApi.startPay(orderInfo)
```

```swift
// iOS - 调用支付宝 SDK
AlipaySDK.defaultService().payOrder(orderInfo, fromScheme: "yourapp") { result in
    // 处理结果
}
```

---

## 当面付 (扫码)

### 构造扫码订单

```typescript
async function createScanPayOrder(
  orderId: string,
  amount: number,
  subject: string,
  authCode: string
) {
  const result = await alipay.exec('alipay.trade.pay', {
    outTradeNo: orderId,
    totalAmount: amount.toString(),
    subject,
    authCode, // 用户支付宝付款码 (扫码枪扫描)
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
  });

  return {
    success: result.code === '10000',
    tradeNo: result.trade_no,
    outTradeNo: result.out_trade_no,
    buyerLogId: result.buyer_log_id,
    message: result.msg,
  };
}
```

### 收银员操作流程

```typescript
router.post('/scan/pay', async (req, res) => {
  try {
    const { orderId, amount, subject, authCode } = req.body;

    const result = await createScanPayOrder(orderId, amount, subject, authCode);

    if (result.success) {
      res.json({ success: true, tradeNo: result.tradeNo });
    } else {
      // 支付失败
      res.json({ success: false, message: result.message });
    }
  } catch (error) {
    console.error('扫码支付失败:', error);
    res.status(500).json({ error: '支付处理失败' });
  }
});
```

---

## 异步通知处理

### 通知验签

```typescript
router.post('/notify', async (req, res) => {
  try {
    const postData = req.body;

    // 1. 验证签名
    const signResult = alipay.checkNotifySign(postData);
    if (!signResult) {
      console.error('签名验证失败:', postData);
      res.status(403).send('fail');
      return;
    }

    // 2. 解析通知数据
    const { trade_status, out_trade_no, trade_no, total_amount, receipt_amount, buyer_logon_id } =
      postData;

    // 3. 业务处理
    if (trade_status === 'TRADE_SUCCESS' || trade_status === 'TRADE_FINISHED') {
      await orderService.updateByTradeNo(out_trade_no, {
        status: 'PAID',
        alipayTradeNo: trade_no,
        paidAmount: parseFloat(total_amount),
        receiptAmount: parseFloat(receipt_amount),
        buyerId: buyer_logon_id,
        paidAt: new Date(),
      });

      // 4. 发送 success 回复
      res.send('success');
    } else {
      res.send('fail');
    }
  } catch (error) {
    console.error('异步通知处理失败:', error);
    res.send('fail');
  }
});
```

### 幂等性处理

```typescript
async function handleNotify(postData: Record<string, string>) {
  const { out_trade_no, trade_status } = postData;

  // 使用 Redis 实现幂等
  const lockKey = `alipay:notify:${out_trade_no}`;
  const lock = await redis.set(lockKey, '1', 'NX', 'EX', 60);

  if (!lock) {
    console.log('重复通知忽略:', out_trade_no);
    return;
  }

  try {
    // 业务处理
    if (trade_status === 'TRADE_SUCCESS') {
      await orderService.updateByTradeNo(out_trade_no, { status: 'PAID' });
    }
  } finally {
    // 锁会自动过期
  }
}
```

---

## 订单查询

```typescript
async function queryOrder(orderId: string) {
  const result = await alipay.exec('alipay.trade.query', {
    out_trade_no: orderId,
  });

  return {
    code: result.code,
    message: result.msg,
    tradeStatus: result.trade_status,
    amount: result.total_amount,
    buyerId: result.buyer_logon_id,
    tradeNo: result.trade_no,
    payTime: result.send_pay_date,
  };
}
```

### 查询结果状态

| trade_status     | 说明     | 处理     |
| ---------------- | -------- | -------- |
| `WAIT_BUYER_PAY` | 等待付款 | 继续等待 |
| `TRADE_CLOSED`   | 交易关闭 | 关闭订单 |
| `TRADE_SUCCESS`  | 支付成功 | 完成订单 |
| `TRADE_FINISHED` | 交易完成 | 完成订单 |

---

## 退款

### 普通退款

```typescript
async function refundOrder(orderId: string, refundAmount: number, reason?: string) {
  const refundId = `REFUND_${orderId}_${Date.now()}`;

  const result = await alipay.exec('alipay.trade.refund', {
    out_trade_no: orderId,
    refund_amount: refundAmount.toString(),
    refund_reason: reason || '用户主动退款',
    out_request_no: refundId,
  });

  return {
    success: result.code === '10000',
    refundId: result.trade_no,
    buyerLogId: result.buyer_log_id,
  };
}
```

### 部分退款

```typescript
router.post('/refund', async (req, res) => {
  try {
    const { orderId, refundAmount, reason } = req.body;

    // 查询原订单
    const order = await orderService.findById(orderId);
    if (!order) {
      res.status(404).json({ error: '订单不存在' });
      return;
    }

    // 验证退款金额
    if (refundAmount > order.paidAmount) {
      res.status(400).json({ error: '退款金额超限' });
      return;
    }

    const result = await refundOrder(orderId, refundAmount, reason);

    if (result.success) {
      await orderService.addRefundRecord(orderId, {
        refundId: result.refundId,
        amount: refundAmount,
        reason,
        status: 'SUCCESS',
      });
      res.json({ success: true, refundId: result.refundId });
    } else {
      res.status(500).json({ error: '退款失败' });
    }
  } catch (error) {
    console.error('退款失败:', error);
    res.status(500).json({ error: '退款处理失败' });
  }
});
```

---

## 退款查询

```typescript
async function queryRefund(orderId: string, refundId: string) {
  const result = await alipay.exec('alipay.trade.fastpay.refund.query', {
    out_trade_no: orderId,
    out_request_no: refundId,
  });

  return {
    code: result.code,
    refundStatus: result.refund_status,
    refundAmount: result.refund_amount,
    refundTime: result.gmt_refund_close,
  };
}
```

---

## 关闭订单

```typescript
async function closeUnpaidOrder(orderId: string) {
  const result = await alipay.exec('alipay.trade.close', {
    out_trade_no: orderId,
  });

  return {
    success: result.code === '10000',
    tradeNo: result.trade_no,
  };
}
```

### 使用场景

```typescript
// 订单超时未支付，自动关闭
async function handleOrderTimeout(orderId: string) {
  const order = await orderService.findById(orderId);

  if (order && order.status === 'PENDING' && isExpired(order.createdAt)) {
    await closeUnpaidOrder(orderId);
    await orderService.updateStatus(orderId, 'CLOSED');
  }
}
```

---

## 安全最佳实践

### 敏感数据保护

```typescript
// ❌ 错误：不验证签名
router.post('/notify', (req, res) => {
  const { status } = req.body;
  orderService.updateStatus(status);
});

// ✅ 正确：验证签名
router.post('/notify', (req, res) => {
  if (!alipay.checkNotifySign(req.body)) {
    res.status(403).send('fail');
    return;
  }
  // 处理业务
});
```

### 密钥安全

```bash
# 环境变量配置 (不提交到代码仓库)
ALIPAY_APP_ID=2021xxxxxx
ALIPAY_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----
ALIPAY_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----
```

### 回调地址

```typescript
// 生产环境必须使用 HTTPS
const config = {
  notifyUrl:
    process.env.NODE_ENV === 'production'
      ? 'https://api.example.com/api/payment/alipay/notify'
      : 'http://localhost:3000/api/payment/alipay/notify',
};
```

---

## 快速检查清单

### 必检项

- [ ] 使用 RSA2 签名 (不用 RSA)
- [ ] 所有回调验证签名
- [ ] 实现幂等性处理
- [ ] 使用 HTTPS 回调地址
- [ ] 敏感信息存环境变量
- [ ] 处理所有错误码
- [ ] 日志记录关键操作

### 测试要点

- [ ] 支付成功流程
- [ ] 支付失败流程
- [ ] 重复通知处理
- [ ] 退款成功流程
- [ ] 退款失败重试
- [ ] 订单超时关闭
- [ ] 签名验证失败

---

## 错误码

| 错误码                | 说明         | 处理方式        |
| --------------------- | ------------ | --------------- |
| `10000`               | 成功         | 业务处理        |
| `20000`               | 服务未知错误 | 重试            |
| `20001`               | 授权权限不足 | 检查 AppId 权限 |
| `40004`               | 业务处理失败 | 检查参数        |
| `ACQ.TRADE_HAS_CLOSE` | 交易已关闭   | 关闭订单        |

---

## 参考

- [支付宝开放平台文档](https://opendocs.alipay.com/)
- [alipay-sdk-nodejs](https://www.npmjs.com/package/alipay-sdk)
- [沙箱环境](https://openhome.alipay.com/develop/sandbox)
